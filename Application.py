#
#   ,----------------------------------,-----------,
#   |     Alunos                       |    DRE    |
#   |----------------------------------|-----------|
#   | Gabriel Izoton Graça de Oliveira | 117056128 |
#   | Daniel Cardoso Cruz de Souza     | 117051136 |
#   | Bruno Gavarra de Araujo          | 113161280 |
#   | Margot Luisa Herin               | 000000000 |
#   | Victor Augusto Souza de Oliveira | 113044501 |
#   | Carolina Hiromi Kameyama         | 116022176 |
#   '----------------------------------'-----------'
#
#    Nome da disciplina: Banco de Dados I
#    Turma: 2019.1
#    
#    Trabalho Prático 1
#
#    Tipo do Script: Aplicação do item H (Inserts, Updates, Deletes, Selects, Relatórios...)
#
#
#
#    !!! IMPORTANTE !!!
#    Este programa assume, por simplicidade, que o arquivo Scripts.sql foi executado completamente.
#    Ou seja, ele assume que o banco de dados já foi criado, as tabelas já foram criadas e os procedimentos já foram criados.
#    Há um motivo para justificar isso:
#
#    -> Devido à limitações com o tempo, não foi possível corrigir um bug no qual o conector do MySQL para Python 
#    executava somente uma instrução por conexão e trava o programa para qualquer instrução subsequente que seja executada.
#
#


import configparser
import mysql.connector
from contextlib import closing
from mysql.connector import errorcode

def loadconfigsection(cfg, section):
    dict1 = {}
    options = cfg.options(section)
    for option in options:
        dict1[option] = cfg.get(section, option)
    return dict1

def firstload():
    dict1 = {}
    dict1['host'] = input('Insira o endereço do servidor: ');
    dict1['database'] = input('Insira o nome do banco de dados: ');
    dict1['user'] = input('Insira o nome de usuario do banco de dados: ');
    dict1['passwd'] = input('Insira a senha do usuario do banco de dados: ');

    Config = configparser.ConfigParser()
    cfgfile = open("config.ini",'w')
    Config.add_section('SQL Connection info')
    Config.set('SQL Connection info','host', dict1['host'])
    Config.set('SQL Connection info','database', dict1['database'])
    Config.set('SQL Connection info','user', dict1['user'])
    Config.set('SQL Connection info','passwd', dict1['passwd'])
    Config.write(cfgfile)
    cfgfile.close()
    
    return dict1

def loadconfig():
    Config = configparser.ConfigParser()
    options = {}
              
    try:
        Config.read('config.ini')
        if not Config.has_section('SQL Connection info'):
            options = firstload()
        else:
            options = loadconfigsection(Config, "SQL Connection info");
    except err:
        print('Problema ao ler o arquivo de configuração.')
        exit()

    return options
    
def connectdb_opt(options):
    try:
        conn = mysql.connector.connect(**options);
        return conn;
    except mysql.connector.Error as err:
      if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Algo deu errado com seu nome de usuário ou senha.")
      elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("O banco de dados especificado não existe.")
      else:
        print(err)
    return None;

def mandaAjuda(c):
    print(  'h',
            'help',
            'sair',
            'novocliente',
            'removecliente',
            'vefiliais',
            'vefuncionarios',
            'vehistorico',
            'veveiculos',
            'veveiculo',
            'atualizakm',
            sep='\n'
            )

def atualizakm(c):
    placa = input('Insira a placa do veiculo: ')

    try:
        c.execute('select count(*) from veiculo where placa = %s', (placa,))
        count = c.fetchone()[0]
        if (count == 0):
            print('Veículo não encontrado. Tente novamente.')
            return
        elif (count > 1):
            print('Ambiguidade na placa do veiculo. Como isso aconteceu? Tente novamente.')
            return
    except mysql.connector.Error as err:
        print("Algo deu errado: {}".format(err))
        return
    
    km = input('Insira a nova kilometragem do veiculo: ')

    try:
        c.callproc('update_kilometragem_carro', args=(placa,km))
        print('Kilometragem modificada com sucesso!')
    except mysql.connector.Error as err:
        print("Algo deu errado: {}".format(err))
        return
    

def veHistorico(c):
    cpf = input('Digite o CPF do cliente: ')
    
    c.execute('CALL get_historico_veiculos_cliente(%s)', (cpf,))
    print ('Modelo        Placa    CPF             Nome')
    for ele1,ele2,ele3,ele4 in c.fetchall():
        print ("{:<14}{:<9}{:<16}{}".format(ele1,ele2,ele4,ele3))
    

def removeCliente(c):
    cpf = input('Digite o CPF do cliente: ')

    try:
        c.execute('select count(*) from cliente where cpf = %s', (cpf,));
        count = c.fetchone()[0]
        if (count == 0):
            print('CPF não encontrado. Tente novamente.')
            return
        elif (count > 1):
            print('Ambiguidade no CPF. Como isso aconteceu? Tente novamente.')
            return
    except mysql.connector.Error as err:
        if ('foreign key constraint fails' in str(err)):
            print('Este cliente não pode ser removido, pois há dados associados a ele.')
        else:
            print("Algo deu errado: {}".format(err))
        return

    resposta = input('Tem certeza que deseja excluir o cliente com CPF = \"{}\"? (s/n) '.format(cpf))
    if (resposta != 's'):
        print('Remoção cancelada.')
        return;

    try:
        c.execute('delete from cliente where cpf = %s', (cpf,));
        print('Cliente removido com sucesso!')
    except mysql.connector.Error as err:
        print("Algo deu errado: {}".format(err))
        return
    

def novoCliente(c):

    a1 = input('Digite o CPF do cliente: ')
    a2 = input('Digite o nome do cliente: ')
    a3 = input('Digite o endereço do cliente: ')
    a4 = input('Digite o telefone do cliente: ')
    a5 = input('Digite a data de nascimento do cliente (no formato yyyy/mm/dd): ')
    a6 = input('Digite o email do cliente: ')
    func_cpf = input('Digite seu CPF, funcionario: ')
    a7 = -1

    try:
        c.execute('select id from funcionario where cpf = %s', (func_cpf,))
        a7 = c.fetchone()
        
    except mysql.connector.Error as err:
        print("Algo deu errado: {}".format(err))
        return
        
    if (a7 == None):
            print('Funcionario nao encontrado. Tente novamente.')
            return
    a7 = a7[0]
    try:
        c.execute(r'insert into cliente (cpf, nome, endereco, tel, nascimento, email, fk_funcionario_id) '
                  r'VALUES (%s, %s, %s, %s, %s, %s, %s)',
                  (a1,a2,a3,a4,a5,a6,a7))
        print('Cliente adicionado com sucesso!')
    except mysql.connector.Error as err:
        if ('Duplicate' in str(err)):
            print('Um cliente com esse CPF ja existe. Tente novamente.')
        elif ('CHECK_tel' in str(err)):
            print('Telefone invalido. Tente novamente.')
        elif ('CHECK_CPF' in str(err)):
            print('CPF do cliente invalido. Tente novamente.')
        elif ('Cliente_Funcionario' in str(err)):
            print('Funcionário nao encontrado. Tente novamente')
        elif ('Incorrect date' in str(err)):
            print('Data de nascimento inválida. Tente novamente')
        else:
            print("Algo deu errado: {}".format(err))

def veFiliais(c):
    
    c.execute('SELECT * FROM filial;')
    for l in c.fetchall():
        print (l[1])
    

def getFilialID(c):
    
    
    filial_end = input('Digite o endereco da filial: ')
    filial_id = -1
    
    c.execute('SELECT * FROM filial WHERE Endereco LIKE %s', ('%'+filial_end+'%',))

    head_rows = c.fetchmany(size=2)
    
    
    if (len(head_rows) == 0):
        print('Endereco nao encontrado. Tente novamente.')
    elif (len(head_rows) > 1):
        print('Nome ambíguo, tente novamente. Você quis dizer "{}" ou "{}"?'.format(*(i[1] for i in head_rows),))
    else:
        filial_id = head_rows[0][0]
    return filial_id

def veVeiculos(c):
    filial_id = getFilialID(c);
    if (filial_id == -1):
        return;

    
    c.execute('CALL get_veiculos_filial(%s)', (filial_id,))
    print ('Modelo        Placa    Endereco')
    for ele1,ele2,ele3,ele4 in c.fetchall():
        print ("{:<14}{:<9}{}".format(ele1,ele2,ele4))

def veVeiculo(c):
    
    placa = input('Digite a placa do veículo: ')
    
    c.execute(  r'SELECT Placa, ano, modelo, kilometragem, endereco FROM veiculo '
                r'JOIN filial ON fk_Filial_ID = ID WHERE Placa = %s', (placa,))
    
    print ('Placa    Ano  Modelo              Kilometragem Endereco')
    for ele1,ele2,ele3,ele4,ele5 in c.fetchall():
        print ("{:<9}{:<5}{:<20}{:<13}{}".format(ele1,ele2,ele3,ele4,ele5))
    

def veFuncionarios(c):
    
    filial_id = getFilialID(c);
    if (filial_id == -1):
        return;
    
    try:
        c.execute('SELECT * FROM funcionario WHERE fk_Filial_ID = %s;', (filial_id,))
        for l in c.fetchall():
            print (l)
    except mysql.connector.Error as err:
      print("Algo deu errado: {}".format(err))

def main():
    print('Locadora v0.1');
    print('Digite \'h\' para ajuda.');
    over = False
    conn.autocommit = True
    c = conn.cursor()
    while not over:
        cmd = input('> ');
        if cmd in commands:
            commands[cmd](c)
            #queria que loopasse pra sempre, mas nao ta funcionando
            exit
        elif cmd == 'sair':
            over = True
        else:
            print('Comando desconhecido. Digite \'h\' para uma lista de comandos.');
            


print('Conectando ao banco de dados...')

options = loadconfig();

conn = connectdb_opt(options);

if (conn == None):
    print('Houve um problema ao se conectar ao banco de dados.');
    exit();

commands = {
    'h': mandaAjuda,
    'help': mandaAjuda,
    'ajuda': mandaAjuda,
    'comandos': mandaAjuda,
    '?': mandaAjuda,
    'novocliente':novoCliente,
    'removecliente':removeCliente,
    'vefiliais':veFiliais,
    'vefuncionarios':veFuncionarios,
    'vehistorico':veHistorico,
    'veveiculos':veVeiculos,
    'veveiculo':veVeiculo,
    'atualizakm':atualizakm
}

main();

conn.close();
