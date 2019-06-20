/*

   ,----------------------------------,-----------,
   |     Alunos                       |    DRE    |
   |----------------------------------|-----------|
   | Gabriel Izoton Graça de Oliveira | 117056128 |
   | Daniel Cardoso Cruz de Souza     | 117051136 |
   | Bruno Gavarra de Araujo          | 113161280 |
   | Margot Luisa Herin               | 119086624 |
   | Victor Augusto Souza de Oliveira | 113044501 |
   | Carolina Hiromi Kameyama         | 116022176 |
   '----------------------------------'-----------'

    Nome da disciplina: Banco de Dados I
    Turma: 2019.1
    
    Trabalho Prático 1

	Sessão 1
    Criação do banco de dados (Criação de tabelas, colunas, RIs, FKs, etc)
	
    
*/

# !!! IMPORTANTE !!! Caso deseje usar outro banco de dados, modifique aqui!
CREATE DATABASE IF NOT EXISTS bd_20191_test;
use bd_20191_test;

DROP TABLE IF EXISTS `cartaocredito`, `cliente`, `filial`, `funcionario`, `gerente`, `incidente`, `locacao_reserva`, 
	`manutencao`, `motorista`, `negocia`, `operacao`, `pagamento`, `transferencia_veiculo_filial_gerente`, `veiculo`;

CREATE TABLE Filial (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Endereco VARCHAR(255) UNIQUE
);

CREATE TABLE Veiculo (
    Placa VARCHAR(7) PRIMARY KEY,
    modelo VARCHAR(40),
    ano INT(4),
    kilometragem INT(7),
    fk_Filial_ID INT,
    CONSTRAINT Veiculo_CHECK_Placa CHECK (Placa REGEXP '[A-Z]{3}[0-9]{4}'),
    CONSTRAINT Veiculo_Filial FOREIGN KEY (fk_Filial_ID) REFERENCES Filial (ID) ON DELETE CASCADE
);

CREATE TABLE Funcionario (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    CPF VARCHAR(14) UNIQUE,
    Nome VARCHAR(50),
    Sobrenome VARCHAR(255),
    fk_Filial_ID INT,
    CONSTRAINT Funcionario_CHECK_CPF CHECK (CPF REGEXP '[0-9]{3}.[0-9]{3}.[0-9]{3}-[0-9]{2}'),
    CONSTRAINT Funcionario_Filial FOREIGN KEY (fk_Filial_ID) REFERENCES Filial (ID) ON DELETE CASCADE
);

CREATE TABLE Gerente (
    IDG INT PRIMARY KEY AUTO_INCREMENT,
    fk_Funcionario_ID INT UNIQUE,
    CONSTRAINT Gerente_Funcionario FOREIGN KEY (fk_Funcionario_ID) REFERENCES Funcionario (ID) ON DELETE CASCADE
);

CREATE TABLE Cliente (
    CPF VARCHAR(14) PRIMARY KEY,
    Nome VARCHAR(50),
    endereco VARCHAR(255),
    tel VARCHAR(13),
    nascimento DATE,
    email VARCHAR(255),
    fk_Funcionario_ID INT,
    CONSTRAINT Cliente_CHECK_tel CHECK (tel REGEXP '[0-9]{2} [0-9]{4,5}-[0-9]{4}'),
    CONSTRAINT Cliente_CHECK_CPF CHECK (CPF REGEXP '[0-9]{3}.[0-9]{3}.[0-9]{3}-[0-9]{2}'),
    CONSTRAINT Cliente_Funcionario FOREIGN KEY (fk_Funcionario_ID) REFERENCES Funcionario (ID) ON DELETE CASCADE
);

CREATE TABLE Motorista (
    CPF VARCHAR(14) PRIMARY KEY,
    nome VARCHAR(50),
    endereco VARCHAR(255),
    tel VARCHAR(13),
    nascimento DATE,
    email VARCHAR(255),
    fk_Cliente_CPF VARCHAR(14),
    CONSTRAINT Motorista_CHECK_tel CHECK (tel REGEXP '[0-9]{2} [0-9]{4,5}-[0-9]{4}'),
    CONSTRAINT Motorista_CHECK_CPF CHECK (CPF REGEXP '[0-9]{3}.[0-9]{3}.[0-9]{3}-[0-9]{2}'),
	CONSTRAINT Motorista_Cliente FOREIGN KEY (fk_Cliente_CPF) REFERENCES Cliente (CPF) ON DELETE CASCADE
);

CREATE TABLE CartaoCredito (
    Numero VARCHAR(16) PRIMARY KEY,
    Validade DATE,
    fk_Cliente_CPF VARCHAR(14),
    CONSTRAINT CartaoCredito_CHECK_Numero CHECK (Numero REGEXP '[0-9]{16}'),
    CONSTRAINT CartaoCredito_Cliente FOREIGN KEY (fk_Cliente_CPF) REFERENCES Cliente (CPF) ON DELETE RESTRICT
);

CREATE TABLE Pagamento (
    Cod INT PRIMARY KEY,
    Pagamento_TIPO INT(1),
    fk_Cliente_CPF VARCHAR(14),
    CONSTRAINT Pagamento_CHECK_Tipo CHECK (Pagamento_TIPO IN (0, 1)),
    CONSTRAINT Pagamento_Cliente FOREIGN KEY (fk_Cliente_CPF) REFERENCES Cliente (CPF) ON DELETE CASCADE
);

CREATE TABLE Locacao_Reserva (
    dataRetirada DATE,
    dataDevolucao DATE,
    dataInicio DATE,
    dataFim DATE,
    ID INT PRIMARY KEY AUTO_INCREMENT,
    valor INT,
    fk_CartaoCredito_Numero VARCHAR(16),
    fk_Veiculo_Placa VARCHAR(7),
    fk_Funcionario_ID INT,
    fk_Pagamento_Cod INT, 
    CONSTRAINT Locacao_Reserva_CartaoCredito FOREIGN KEY (fk_CartaoCredito_Numero) REFERENCES CartaoCredito (Numero), 
    CONSTRAINT Locacao_Reserva_Veiculo FOREIGN KEY (fk_Veiculo_Placa) REFERENCES Veiculo (Placa) ON DELETE CASCADE, 
    CONSTRAINT Locacao_Reserva_Funcionario FOREIGN KEY (fk_Funcionario_ID) REFERENCES Funcionario (ID) ON DELETE CASCADE,
    CONSTRAINT Locacao_Reserva_Pagamento FOREIGN KEY (fk_Pagamento_Cod) REFERENCES Pagamento (Cod) ON DELETE SET NULL
);

CREATE TABLE Incidente (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    data DATE,
    valor INT,
    fk_Reserva_ID INT,
    CONSTRAINT Incidente_Reserva FOREIGN KEY (fk_Reserva_ID) REFERENCES Locacao_Reserva (ID)
);

CREATE TABLE Manutencao (
    dataInicio DATE,
    dataFim DATE,
    Descricao VARCHAR(255),
    fk_Veiculo_Placa VARCHAR(7),
    fk_Gerente_IDG INT,
    CONSTRAINT Manutencao_Veiculo FOREIGN KEY (fk_Veiculo_Placa) REFERENCES Veiculo (Placa) ON DELETE CASCADE,
    CONSTRAINT Manutencao_Gerente FOREIGN KEY (fk_Gerente_IDG) REFERENCES Gerente (IDG) ON DELETE CASCADE
);

CREATE TABLE Operacao (
    Cod INT PRIMARY KEY,
    data DATE,
    valor INT,
    Operacao_TIPO INT(1),
    fk_Gerente_IDG INT,
    CONSTRAINT Operacao_CHECK_Tipo CHECK (Operacao_TIPO IN (0, 1)),
    CONSTRAINT Operacao_Gerente FOREIGN KEY (fk_Gerente_IDG) REFERENCES Gerente (IDG) ON DELETE CASCADE
);

CREATE TABLE Transferencia_Veiculo_Filial_Gerente (
    fk_Veiculo_Placa VARCHAR(7),
    fk_Filial_ID_1 INT,
    fk_Filial_ID_2 INT,
    fk_Gerente_IDG INT,	
    CONSTRAINT Transferencia_Veiculo FOREIGN KEY (fk_Veiculo_Placa) REFERENCES Veiculo (Placa) ON DELETE RESTRICT,
	CONSTRAINT Transferencia_Filial1 FOREIGN KEY (fk_Filial_ID_1) REFERENCES Filial (ID) ON DELETE NO ACTION,
    CONSTRAINT Transferencia_Filial2 FOREIGN KEY (fk_Filial_ID_2) REFERENCES Filial (ID) ON DELETE NO ACTION,
    CONSTRAINT Transferencia_Gerente FOREIGN KEY (fk_Gerente_IDG) REFERENCES Gerente (IDG) ON DELETE RESTRICT
);

CREATE TABLE Negocia (
    fk_Veiculo_Placa VARCHAR(8),
    fk_Operacao_Cod INT, 
    CONSTRAINT Negocia_Veiculo FOREIGN KEY (fk_Veiculo_Placa) REFERENCES Veiculo (Placa) ON DELETE RESTRICT,
    CONSTRAINT Negocia_Operacao FOREIGN KEY (fk_Operacao_Cod) REFERENCES Operacao (Cod) ON DELETE SET NULL
);
    
/*

	Nome da disciplina: Banco de Dados I
	Turma: 2019.1
    
	Trabalho Prático 1

	Sessão 2
	População do banco de dados (Inserts)

*/

insert into filial (endereco) values 
('15627 Gina Hill'), 
('9 Elgar Pass'), 
('86 Talmadge Terrace'), 
('2970 Elgar Alley'), 
('67666 3rd Plaza'), 
('10213 Northridge Terrace');

insert into veiculo (Placa, Modelo, ano, kilometragem, fk_filial_id) values 
('ESA9229', 'Meriva', 2016, 1298, 6),
('VXF0628', 'D150', 2009, 19806, 4),
('KWE3657', 'D150', 2015, 36254, 3),
('LVQ2864', 'Meriva', 2009, 83456, 1),
('LIQ6615', 'Mirage', 2006, 42615, 3),
('QWX8043', 'D150', 2012, 62383, 1),
('ZUF6442', 'Passat', 2008, 86839, 4),
('ONZ9142', 'Mirage', 2010, 16858, 2),
('HUF0630', 'Integra', 2016, 1562, 2),
('QRV9560', 'Meriva', 2008, 22036, 4),
('QZC4039', 'Mirage', 2003, 77512, 2),
('BQW2696', 'Integra', 2018, 94707, 3),
('QTJ7481', 'Range Rover Classic', 2016, 30037, 2),
('LFD5129', 'Range Rover Classic', 2012, 79082, 6),
('BOD6456', 'Mirage', 2016, 80042, 2),
('WCU7435', 'D150', 2006, 66184, 1),
('HKC2075', 'Mirage', 2011, 72044, 5),
('HIS9889', 'Mirage', 2011, 91976, 6),
('FWR5055', 'Meriva', 2017, 88270, 1),
('AXV8242', 'Passat', 2006, 49193, 4),
('TLH1957', 'Range Rover Classic', 2013, 13800, 4),
('BDZ2271', 'Meriva', 2008, 42441, 3),
('DST8994', 'D150', 2006, 40318, 6),
('UEI7297', 'Mirage', 2012, 75924, 3),
('EKB8886', 'Passat', 2011, 74463, 5),
('EJG0751', 'Meriva', 2004, 11940, 5),
('CRD7250', 'Meriva', 2014, 72971, 3),
('RDV7473', 'Range Rover Classic', 2007, 92993, 6),
('FAK3425', 'Range Rover Classic', 2014, 39917, 3),
('VBQ6295', 'Integra', 2010, 54208, 5),
('OSH6282', 'Mirage', 2013, 21861, 2),
('YAX7488', 'Passat', 2015, 98060, 3),
('IGV8025', 'Mirage', 2018, 83459, 3),
('RIG0081', 'Passat', 2007, 69725, 1),
('LBP8889', 'Passat', 2017, 76778, 1),
('WKP5966', 'Integra', 2007, 32448, 6),
('TYC5213', 'Passat', 2007, 64048, 3),
('MUQ1793', 'Meriva', 2004, 48778, 3),
('EXM4840', 'Integra', 2013, 20780, 6),
('DTH4206', 'Passat', 2003, 91843, 1),
('QJK0624', 'HB20', 2019, 102, 3);

insert into funcionario (cpf, nome, sobrenome, fk_filial_id) values 
('196.802.226-03', 'Bay', 'Durling', 4),
('666.133.511-65', 'Katrina', 'Janowski', 2),
('333.191.721-28', 'Salli', 'Wansbury', 4),
('849.793.530-80', 'Nicko', 'Dawtry', 1),
('520.628.282-12', 'Carissa', 'Yate', 4),
('586.829.385-59', 'Pamela', 'Edwards', 2),
('952.531.971-41', 'Leilah', 'Crichten', 4),
('171.607.643-78', 'Audra', 'Hulburt', 6),
('315.824.728-28', 'Salomi', 'Colcomb', 3),
('717.414.399-93', 'Johann', 'Poznanski', 5),
('869.226.589-96', 'Casandra', 'Rolf', 5),
('976.290.780-17', 'Myra', 'Loades', 3),
('008.471.886-82', 'Art', 'Duffett', 2),
('037.717.176-16', 'Ezekiel', 'Du Hamel', 2),
('998.293.163-73', 'Alene', 'Willshee', 4),
('062.005.074-59', 'Astrid', 'Semble', 2),
('267.295.736-26', 'Boony', 'Lamp', 5),
('100.832.858-55', 'Jackelyn', 'Spall', 3),
('917.627.253-66', 'Sibbie', 'McClymond', 2),
('456.838.660-70', 'Cassie', 'McNeish', 1),
('413.805.264-25', 'Mia', 'Laxton', 6);

insert into Gerente (fk_funcionario_id) values (19),
(12),
(21),
(11),
(10),
(7);

insert into cliente (cpf, nome, endereco, tel, nascimento, email, fk_funcionario_id) values 
('917.627.253-66', 'Sibbie McClymond', '775 Arrowood Junction', '21 97901-3227', '1988/01/24', 'bbiecly@uiuc.edu.org', 5),
('456.838.660-70', 'Cassie McNeish', '54 Towne Blvd', '72 90438-1874', '1975/02/05', 'cmneis@dontpad.org', 8),
('413.805.264-25', 'Mia Laxton', '868 Laurel Street', '11 66432-2240', '1986/01/27', 'wluby2@google.com', 14);

insert into cliente (cpf, nome, endereco, tel, nascimento, email, fk_funcionario_id) values 
('551.753.653-02', 'Christabella Finicj', '39422 Arrowood Junction', '28 0179-3272', '1988/01/24', 'cfinicj0@uiuc.edu', 5),
('541.421.625-79', 'Valentine Presho', '02 Towne Drive', '75 70348-1944', '1965/12/25', 'vpresho1@apache.org', 8),
('165.661.113-85', 'Witty Luby', '88 Laurel Circle', '15 6472-1840', '1982/11/17', 'wluby2@typepad.com', 14),
('130.133.676-15', 'Clement Sergean', '9 Fieldstone Place', '92 3711-0010', '1963/12/20', 'csergean3@tmall.com', 1),
('279.134.410-94', 'Garrett Libreros', '4 Ronald Regan Place', '45 5306-7013', '1984/05/15', 'glibreros4@over-blog.com', 17),
('144.107.113-27', 'Celeste Erat', '09414 Pearson Point', '82 21756-5058', '1966/09/28', 'cerat5@domainmarket.com', 18),
('954.585.915-16', 'Romain Really', '54845 Sycamore Parkway', '86 59385-6606', '1985/12/13', 'rreally6@ameblo.jp', 12),
('166.165.606-14', 'Riccardo Balderson', '13444 Kenwood Park', '76 10088-9012', '1974/09/17', 'rbalderson7@barnesandnoble.com', 13),
('629.635.572-68', 'Niles Dautry', '9995 Canary Place', '17 3130-1842', '1989/02/17', 'ndautry8@nhs.uk', 15),
('516.179.951-13', 'Vallie Oleszcuk', '97 Westerfield Avenue', '17 4365-7238', '1969/09/29', 'voleszcuk9@a8.net', 18),
('360.485.474-56', 'Lynnette Assaf', '02041 Monterey Park', '20 15928-4505', '1969/10/03', 'lassafa@go.com', 21),
('575.521.610-37', 'Ashia Levee', '7859 Bunker Hill Terrace', '90 28898-0326', '1987/09/29', 'aleveeb@va.gov', 16),
('116.861.478-03', 'Coralie Ricardo', '9 Crowley Court', '73 26668-7583', '1986/06/13', 'cricardoc@patch.com', 17),
('723.823.320-68', 'Dory Ragate', '540 Pleasure Circle', '16 0694-8100', '1988/03/25', 'dragated@google.co.jp', 20),
('649.852.880-92', 'Maurene Urwin', '054 Steensland Park', '90 5012-2757', '1962/11/10', 'murwine@blogger.com', 19),
('340.253.322-86', 'Kimball Gelsthorpe', '04538 Derek Park', '54 8910-6167', '1965/01/16', 'kgelsthorpef@last.fm', 12),
('742.673.517-77', 'Raddie Dulieu', '21 Prentice Avenue', '51 2203-5887', '1974/07/14', 'rdulieug@w3.org', 5),
('369.186.788-27', 'Buckie Sexton', '8723 Fairview Place', '29 08374-4487', '1977/09/23', 'bsextonh@scribd.com', 16),
('712.055.970-34', 'Melina Egger', '416 Forest Circle', '90 32961-6458', '1984/06/25', 'meggeri@wordpress.com', 19),
('436.705.137-01', 'Free Schimank', '45 American Ash Court', '22 13090-3791', '1970/02/12', 'fschimankj@time.com', 1),
('413.654.032-10', 'Ali Teall', '6098 Cardinal Place', '70 5256-2745', '1967/02/13', 'ateallk@gnu.org', 2),
('446.836.849-32', 'Maureen Bickerstaffe', '22733 Burning Wood Avenue', '92 73965-1238', '1981/12/26', 'mbickerstaffel@blogger.com', 3),
('227.096.607-44', 'Sherie Hatto', '65310 Tennyson Parkway', '97 9829-5275', '1972/10/11', 'shattom@dyndns.org', 12),
('461.456.100-93', 'Claudina Vorley', '66 Nobel Hill', '04 7912-8924', '1965/03/04', 'cvorleyn@google.com.hk', 16),
('868.545.070-28', 'Melodie Reedick', '18822 Morningstar Parkway', '65 0586-8396', '1985/01/25', 'mreedicko@nps.gov', 17),
('363.253.921-42', 'Laird Cheeney', '183 Aberg Drive', '61 72208-5127', '1989/02/18', 'lcheeneyp@discuz.net', 21),
('722.765.786-52', 'Thebault Poge', '2472 Delaware Place', '27 7304-2936', '1976/10/22', 'tpogeq@free.fr', 6),
('005.981.956-22', 'Ariana Silversmidt', '6 Sage Road', '97 65444-3433', '1981/06/13', 'asilversmidtr@bing.com', 16),
('966.791.837-13', 'Stevana Castellet', '32123 Hudson Hill', '89 4598-8017', '1965/03/03', 'scastellets@wunderground.com', 3),
('526.717.236-39', 'Torry Haddow', '8 Jenna Avenue', '54 8547-4899', '1971/07/01', 'thaddowt@ifeng.com', 12),
('163.331.347-06', 'Cookie Snawden', '896 Mccormick Parkway', '08 3366-1040', '1987/08/19', 'csnawdenu@timesonline.co.uk', 16),
('101.169.556-21', 'Tyrone Dumbrill', '2060 Reinke Pass', '61 6354-0622', '1975/10/17', 'tdumbrillv@godaddy.com', 4),
('745.156.491-93', 'Doro Gladwell', '58 Erie Parkway', '54 92903-0991', '1981/03/19', 'dgladwellw@ustream.tv', 2),
('439.926.952-83', 'Isidro Mobius', '68915 Norway Maple Circle', '77 05332-1558', '1986/06/04', 'imobiusx@zdnet.com', 4),
('441.093.495-58', 'Zorine Bewshea', '0 Leroy Plaza', '33 9080-0321', '1974/03/27', 'zbewsheay@icio.us', 7),
('193.730.252-26', 'Eimile Jurgenson', '25 Crownhardt Court', '90 5414-0898', '1968/05/12', 'ejurgensonz@biblegateway.com', 7),
('437.730.798-93', 'Adria Kornyshev', '581 Blackbird Crossing', '37 93747-6616', '1968/11/06', 'akornyshev10@amazon.de', 9),
('955.674.466-67', 'Katheryn MacQuaker', '71438 East Drive', '18 3535-2039', '1984/05/05', 'kmacquaker11@fema.gov', 6),
('690.698.534-49', 'Pancho Corwood', '253 Dakota Crossing', '67 7851-6438', '1983/06/15', 'pcorwood12@miibeian.gov.cn', 10),
('617.754.443-96', 'Federica Caberas', '469 Fisk Drive', '27 1353-9357', '1980/02/24', 'fcaberas13@freewebs.com', 16),
('633.420.255-81', 'Cam Neeson', '8 Rieder Hill', '67 10089-6442', '1987/03/08', 'cneeson14@liveinternet.ru', 13),
('532.238.389-00', 'Wren Surman-Wells', '3 Jay Trail', '85 5938-2353', '1985/11/20', 'wsurmanwells15@themeforest.net', 4),
('031.815.041-85', 'Klemens McGeady', '769 Sloan Alley', '88 52477-4514', '1961/07/26', 'kmcgeady16@comsenz.com', 14),
('277.442.596-61', 'Dom Shafe', '953 Rutledge Place', '59 20078-7565', '1988/01/04', 'dshafe17@whitehouse.gov', 14),
('712.861.332-39', 'Casandra Tottem', '67 Dryden Point', '80 50581-0549', '1983/11/21', 'ctottem18@reddit.com', 16),
('734.497.094-21', 'Basilio Lakenden', '2 Pond Road', '23 1960-2266', '1970/09/29', 'blakenden19@ucla.edu', 2),
('531.571.851-68', 'Georgie Padly', '0925 Birchwood Crossing', '10 46449-9251', '1970/11/23', 'gpadly1a@sfgate.com', 11),
('767.354.449-90', 'Zollie Ranstead', '22 Kropf Plaza', '86 4085-0127', '1988/07/25', 'zranstead1b@merriam-webster.com', 2),
('289.191.196-40', 'Daffy Hayfield', '609 Loomis Lane', '27 8657-4396', '1985/01/25', 'dhayfield1c@unesco.org', 15),
('442.763.048-82', 'Milli Thorn', '1 Saint Paul Terrace', '52 8204-8643', '1981/11/19', 'mthorn1d@is.gd', 11),
('008.253.290-46', 'Marys Bunney', '1 Fairview Lane', '96 91660-2623', '1988/06/12', 'mbunney1e@go.com', 17),
('882.192.714-48', 'Audre Huws', '70256 John Wall Point', '73 9085-9671', '1978/02/23', 'ahuws1f@dagondesign.com', 3),
('647.776.121-17', 'Mercie Corrington', '5 Pawling Hill', '87 02919-6544', '1988/06/21', 'mcorrington1g@360.cn', 4),
('677.261.522-10', 'Merwin Washtell', '784 Village Green Point', '80 36829-3039', '1970/07/11', 'mwashtell1h@mysql.com', 7),
('750.304.004-88', 'Bendix Magog', '1481 Talisman Parkway', '38 6999-3407', '1985/08/27', 'bmagog1i@youku.com', 13),
('276.610.118-24', 'Sisely Helder', '73790 Nova Hill', '36 9300-0221', '1976/11/13', 'shelder1j@accuweather.com', 15),
('533.842.589-85', 'Kalila Klimashevich', '01658 Emmet Pass', '85 8844-3946', '1968/10/04', 'kklimashevich1k@techcrunch.com', 13),
('531.007.052-94', 'Welbie Brizland', '0 Pawling Terrace', '48 18462-4161', '1963/11/03', 'wbrizland1l@seattletimes.com', 9),
('133.111.108-13', 'Rawley Belsey', '30332 Canary Place', '63 58648-4575', '1962/01/14', 'rbelsey1m@washington.edu', 5),
('061.376.881-44', 'Michaela Cisco', '94 Arizona Court', '21 1141-2282', '1989/07/09', 'mcisco1n@shinystat.com', 2),
('402.097.132-05', 'Prudi Mulvany', '1 Acker Trail', '97 5820-7537', '1987/04/10', 'pmulvany1o@reference.com', 9),
('556.153.810-80', 'Artemus Tumilty', '803 Darwin Terrace', '33 71167-5143', '1973/10/19', 'atumilty1p@youtube.com', 10),
('264.822.047-58', 'Clerissa Jancic', '33 Cordelia Circle', '69 89033-4935', '1987/07/25', 'cjancic1q@amazon.co.uk', 2),
('318.944.059-81', 'Jonah Boness', '7680 Hallows Road', '20 86332-0533', '1983/01/15', 'jboness1r@mashable.com', 14),
('341.457.395-88', 'Arielle Sandbatch', '2 Sunnyside Court', '26 41370-0467', '1985/06/04', 'asandbatch1s@ca.gov', 8),
('237.179.782-68', 'Glad Antunez', '4 Kipling Avenue', '22 7047-2234', '1976/08/09', 'gantunez1t@51.la', 16),
('492.550.597-38', 'Wenda McIllroy', '33991 Leroy Junction', '09 85049-3054', '1968/06/26', 'wmcillroy1u@domainmarket.com', 9),
('281.505.763-16', 'Fredelia Wrist', '2 Dwight Parkway', '06 07824-0398', '1984/05/08', 'fwrist1v@wisc.edu', 4),
('805.462.760-01', 'Jo Dron', '6 Golden Leaf Alley', '04 0389-1081', '1967/07/27', 'jdron1w@zimbio.com', 2),
('162.835.688-45', 'Siusan Vaudre', '41 Doe Crossing Terrace', '26 82688-5498', '1985/04/26', 'svaudre1x@gizmodo.com', 9),
('957.783.120-41', 'Irma Tingey', '21 Parkside Court', '84 0784-5812', '1966/11/15', 'itingey1y@yelp.com', 12),
('839.385.633-33', 'Idaline Leggate', '7 Mallard Court', '67 6824-9608', '1967/09/26', 'ileggate1z@japanpost.jp', 14),
('959.307.874-14', 'Phillipe Harrold', '0410 Upham Street', '34 4374-6896', '1966/06/04', 'pharrold20@vimeo.com', 16),
('787.833.224-53', 'Ruby Tidey', '023 Hayes Terrace', '64 42454-0984', '1975/08/18', 'rtidey21@aboutads.info', 8),
('006.426.753-34', 'Fitzgerald O''Deoran', '8853 Mendota Lane', '75 3588-9984', '1988/03/31', 'fodeoran22@gmpg.org', 5),
('119.890.665-76', 'Syman Mathew', '2 Parkside Point', '19 6447-8683', '1966/10/28', 'smathew23@netscape.com', 10),
('982.141.117-21', 'Rhiamon Phelipeaux', '2 Bunker Hill Street', '12 05277-0278', '1964/12/13', 'rphelipeaux24@qq.com', 17),
('587.481.941-11', 'Sax Penberthy', '6857 Luster Circle', '81 6896-1214', '1974/06/17', 'spenberthy25@freewebs.com', 17),
('062.777.968-51', 'Francisca MacCaull', '89 6th Parkway', '64 9393-4828', '1965/02/11', 'fmaccaull26@intel.com', 11),
('444.862.886-52', 'Heloise Guirardin', '352 Arrowood Court', '11 58601-3699', '1977/10/07', 'hguirardin27@msu.edu', 20),
('554.066.740-55', 'Othelia Hundey', '5810 Graedel Trail', '64 2340-1275', '1990/03/05', 'ohundey28@youku.com', 4),
('779.201.171-12', 'Isidro Gerholz', '39016 Lakewood Gardens Way', '25 5014-4863', '1970/10/31', 'igerholz29@google.es', 10),
('063.317.120-43', 'Keene Cremer', '952 American Center', '29 97853-3428', '1981/09/18', 'kcremer2a@zimbio.com', 13),
('771.952.976-79', 'Ricki Revel', '750 School Plaza', '00 85584-9175', '1973/06/18', 'rrevel2b@jalbum.net', 15);

insert into motorista (cpf, nome, endereco, tel, nascimento, email, fk_cliente_cpf) values 
('551.753.653-02', 'Christabella Finicj', '39422 Arrowood Junction', '28 0179-3272', '1988/01/24', 'cfinicj0@uiuc.edu', '551.753.653-02'),
('541.421.625-79', 'Valentine Presho', '02 Towne Drive', '75 70348-1944', '1965/12/25', 'vpresho1@apache.org', '541.421.625-79'),
('165.661.113-85', 'Witty Luby', '88 Laurel Circle', '15 6472-1840', '1982/11/17', 'wluby2@typepad.com', '165.661.113-85'),
('130.133.676-15', 'Clement Sergean', '9 Fieldstone Place', '92 3711-0010', '1963/12/20', 'csergean3@tmall.com', '130.133.676-15'),
('279.134.410-94', 'Garrett Libreros', '4 Ronald Regan Place', '45 5306-7013', '1984/05/15', 'glibreros4@over-blog.com', '279.134.410-94'),
('144.107.113-27', 'Celeste Erat', '09414 Pearson Point', '82 21756-5058', '1966/09/28', 'cerat5@domainmarket.com', '144.107.113-27'),
('954.585.915-16', 'Romain Really', '54845 Sycamore Parkway', '86 59385-6606', '1985/12/13', 'rreally6@ameblo.jp', '954.585.915-16'),
('166.165.606-14', 'Riccardo Balderson', '13444 Kenwood Park', '76 10088-9012', '1974/09/17', 'rbalderson7@barnesandnoble.com', '166.165.606-14'),
('629.635.572-68', 'Niles Dautry', '9995 Canary Place', '17 3130-1842', '1989/02/17', 'ndautry8@nhs.uk', '629.635.572-68'),
('516.179.951-13', 'Vallie Oleszcuk', '97 Westerfield Avenue', '17 4365-7238', '1969/09/29', 'voleszcuk9@a8.net', '516.179.951-13');

insert into motorista (cpf, nome, endereco, tel, nascimento, email, fk_cliente_cpf) values 
('364.623.609-18', 'Serge O''Shee', '9759 Arizona Center', '86 5373-6984', '1982/03/01', 'soshee0@desdev.cn', '063.317.120-43'),
('187.413.580-10', 'Blaine Capeloff', '96735 1st Avenue', '80 90984-4223', '1987/09/27', 'bcapeloff1@liveinternet.ru', '647.776.121-17'),
('505.107.783-49', 'Gates Schruurs', '26 Waxwing Lane', '31 34276-1341', '1989/10/25', 'gschruurs2@sina.com.cn', '276.610.118-24'),
('216.722.576-08', 'Hilliary Priddey', '02 Clyde Gallagher Court', '03 09899-0822', '1971/08/21', 'hpriddey3@toplist.cz', '277.442.596-61'),
('065.412.071-38', 'Missie Garaway', '30962 Kings Junction', '50 22335-6986', '1980/12/17', 'mgaraway4@nymag.com', '116.861.478-03'),
('888.137.042-67', 'Bobbe Polding', '474 Schiller Parkway', '41 77842-8320', '1983/12/04', 'bpolding5@aol.com', '526.717.236-39'),
('868.491.609-97', 'Sabine Philipp', '07757 Browning Lane', '36 99873-1115', '1984/05/02', 'sphilipp6@economist.com', '787.833.224-53'),
('566.330.674-40', 'Bourke Houten', '949 Crowley Crossing', '97 47547-5467', '1965/01/21', 'bhouten7@phpbb.com', '492.550.597-38'),
('526.136.883-82', 'Victor Holmyard', '36 Charing Cross Point', '20 4558-0126', '1976/01/11', 'vholmyard8@jiathis.com', '633.420.255-81'),
('068.599.459-73', 'Gal Happs', '35426 Forest Dale Crossing', '82 90146-2719', '1971/06/20', 'ghapps9@woothemes.com', '779.201.171-12'),
('798.274.308-40', 'Andrea Levermore', '36588 Hermina Street', '25 73109-0376', '1983/06/01', 'alevermorea@soundcloud.com', '575.521.610-37'),
('764.307.266-07', 'Walker Gibbett', '47091 Blackbird Parkway', '93 96669-1629', '1975/10/06', 'wgibbettb@edublogs.org', '492.550.597-38'),
('428.593.716-39', 'Zorine New', '61912 Golden Leaf Way', '32 64283-4174', '1967/03/29', 'znewc@squidoo.com', '554.066.740-55'),
('750.234.593-35', 'Sheelagh Killigrew', '97727 Derek Terrace', '50 7329-3456', '1977/03/18', 'skilligrewd@ameblo.jp', '954.585.915-16'),
('776.797.808-27', 'Lenora Barbour', '26 Golf Course Trail', '74 32106-4002', '1977/06/22', 'lbarboure@msn.com', '647.776.121-17'),
('350.333.130-99', 'Nerty Piche', '3961 Barby Lane', '68 4360-3974', '1984/06/07', 'npichef@163.com', '554.066.740-55'),
('426.047.961-54', 'Doe O''Dowgaine', '12 Carey Way', '47 1500-3520', '1980/07/08', 'dodowgaineg@liveinternet.ru', '165.661.113-85'),
('101.049.226-38', 'Josias McKerlie', '67 Meadow Ridge Center', '95 9058-4944', '1979/05/08', 'jmckerlieh@techcrunch.com', '341.457.395-88'),
('573.264.000-99', 'Griffith Brownsword', '1 Oak Hill', '31 19974-3693', '1963/08/26', 'gbrownswordi@skype.com', '166.165.606-14'),
('425.259.256-63', 'Wandie Ransfield', '0405 Fairview Terrace', '79 6132-9338', '1984/02/06', 'wransfieldj@odnoklassniki.ru', '587.481.941-11'),
('206.058.150-01', 'Darsey Fydoe', '2360 Hoard Place', '12 09867-1075', '1974/04/09', 'dfydoek@youtube.com', '805.462.760-01'),
('297.270.042-05', 'Edeline Beevor', '890 Sherman Avenue', '03 99006-3573', '1974/01/09', 'ebeevorl@acquirethisname.com', '276.610.118-24'),
('052.375.125-48', 'Rickey Paeckmeyer', '9 Monica Place', '26 59479-7900', '1978/10/30', 'rpaeckmeyerm@netscape.com', '959.307.874-14'),
('055.603.392-52', 'Drucy Le Bosse', '6177 Garrison Hill', '16 37184-0331', '1964/03/26', 'dlen@tinypic.com', '341.457.395-88'),
('302.873.437-30', 'Evelin Innis', '2 Summer Ridge Way', '76 18099-0773', '1988/04/22', 'einniso@ezinearticles.com', '554.066.740-55'),
('731.947.628-75', 'Cynthie Croker', '524 Susan Parkway', '02 0013-0830', '1970/03/23', 'ccrokerp@stumbleupon.com', '006.426.753-34'),
('593.307.383-56', 'Gualterio Stockey', '67 Macpherson Way', '60 8558-3013', '1985/05/01', 'gstockeyq@usda.gov', '805.462.760-01'),
('006.971.339-90', 'Berte Ride', '3234 Forest Drive', '00 9343-1914', '1976/04/05', 'brider@t.co', '402.097.132-05'),
('235.981.254-58', 'Thomasina Cryer', '03619 Stoughton Plaza', '54 3159-2096', '1964/08/13', 'tcryers@hatena.ne.jp', '279.134.410-94'),
('731.046.873-82', 'Kalli Kupke', '762 Lakewood Hill', '33 13365-1896', '1986/08/05', 'kkupket@fema.gov', '779.201.171-12'),
('452.964.381-18', 'Ellette Allanson', '8 Milwaukee Place', '05 8394-9377', '1978/10/05', 'eallansonu@paginegialle.it', '165.661.113-85'),
('425.718.968-99', 'Clevey Vannacci', '60 Helena Terrace', '01 16553-6524', '1966/03/21', 'cvannacciv@homestead.com', '750.304.004-88'),
('368.016.628-06', 'Clary Barles', '25678 Dunning Center', '25 0164-1245', '1972/07/29', 'cbarlesw@berkeley.edu', '444.862.886-52'),
('798.872.503-00', 'Reade Blabey', '30 Melvin Junction', '24 47675-7816', '1966/12/29', 'rblabeyx@usa.gov', '061.376.881-44'),
('744.707.126-82', 'Maurice Hechlin', '5173 Vermont Road', '04 61651-7515', '1970/03/16', 'mhechliny@bloglines.com', '360.485.474-56'),
('878.222.125-90', 'Ronnie Blemen', '968 Warrior Junction', '76 8807-9537', '1971/11/26', 'rblemenz@discovery.com', '363.253.921-42'),
('841.706.236-40', 'Enrica Jiruca', '218 Bartillon Parkway', '85 46593-9380', '1965/09/21', 'ejiruca10@so-net.ne.jp', '006.426.753-34'),
('332.828.461-10', 'Raddie Markie', '725 Schmedeman Way', '16 2924-7110', '1973/09/02', 'rmarkie11@narod.ru', '779.201.171-12'),
('538.952.883-18', 'Silvain Wyndham', '74 Sachtjen Place', '47 9007-1836', '1973/03/05', 'swyndham12@elegantthemes.com', '533.842.589-85'),
('211.346.608-27', 'Hazel Jeal', '4 Sunbrook Circle', '59 98151-9059', '1967/04/02', 'hjeal13@dell.com', '531.007.052-94'),
('877.769.408-37', 'Ellyn But', '74996 Gale Center', '95 43022-4376', '1969/08/23', 'ebut14@narod.ru', '166.165.606-14'),
('927.619.291-60', 'Niko Brearty', '3 Fieldstone Way', '01 2209-9838', '1967/08/15', 'nbrearty15@ebay.com', '264.822.047-58'),
('446.289.596-36', 'Allyn Poolman', '458 Anthes Point', '58 33687-6267', '1973/02/08', 'apoolman16@devhub.com', '959.307.874-14'),
('596.476.469-13', 'Montgomery Boutflour', '8 Shoshone Hill', '23 6263-3753', '1987/08/09', 'mboutflour17@imageshack.us', '413.654.032-10'),
('338.910.210-56', 'Ada Cheeseman', '948 Mallard Center', '38 03445-1839', '1988/10/21', 'acheeseman18@wordpress.com', '437.730.798-93'),
('866.499.815-93', 'Sheeree Malinowski', '501 Colorado Street', '33 5759-2012', '1974/05/22', 'smalinowski19@tinyurl.com', '369.186.788-27'),
('715.811.352-84', 'Holly-anne Milan', '02140 Namekagon Pass', '06 7899-2266', '1973/11/13', 'hmilan1a@uol.com.br', '063.317.120-43'),
('108.737.077-33', 'Rhodie Kiefer', '30082 Badeau Lane', '61 0551-2649', '1972/05/14', 'rkiefer1b@163.com', '734.497.094-21'),
('127.446.477-69', 'Gwenneth Presley', '99 Kropf Park', '33 04839-6862', '1967/09/19', 'gpresley1c@google.co.uk', '959.307.874-14'),
('377.901.405-79', 'Nathalia Boow', '6114 Blackbird Pass', '30 6269-7618', '1969/05/07', 'nboow1d@acquirethisname.com', '008.253.290-46'),
('857.018.716-07', 'Tomi Mongenot', '79 Leroy Lane', '13 61599-7234', '1966/07/04', 'tmongenot1e@biblegateway.com', '360.485.474-56'),
('619.040.405-51', 'Georgianne Kenion', '08 Corben Parkway', '03 31620-2390', '1984/08/16', 'gkenion1f@merriam-webster.com', '264.822.047-58'),
('065.839.776-09', 'Willamina Armer', '733 Eagan Parkway', '38 2220-2023', '1966/08/18', 'warmer1g@merriam-webster.com', '533.842.589-85'),
('663.558.376-63', 'Judi Petters', '3878 Corry Parkway', '37 9169-2973', '1979/01/28', 'jpetters1h@arizona.edu', '436.705.137-01'),
('513.789.749-25', 'Kore Bettington', '88 Ramsey Trail', '58 53990-3260', '1971/03/08', 'kbettington1i@reverbnation.com', '554.066.740-55'),
('135.383.642-62', 'Orran Logie', '9 Gina Alley', '07 71541-0855', '1978/11/22', 'ologie1j@xing.com', '532.238.389-00'),
('181.695.427-82', 'Euell Loving', '32 Nancy Parkway', '86 2392-6210', '1986/03/06', 'eloving1k@gnu.org', '437.730.798-93'),
('319.663.087-38', 'Gretal Sockell', '754 Westerfield Road', '21 8095-3341', '1961/09/08', 'gsockell1l@free.fr', '575.521.610-37'),
('830.798.096-16', 'Alistair Ianizzi', '7818 Debra Park', '89 3066-0197', '1968/01/09', 'aianizzi1m@engadget.com', '031.815.041-85'),
('421.644.830-95', 'Dolores Gideon', '180 Morrow Lane', '45 92489-1501', '1986/05/16', 'dgideon1n@sciencedaily.com', '868.545.070-28'),
('050.028.713-94', 'Tremayne Pool', '9009 Sage Plaza', '47 8056-3558', '1965/04/05', 'tpool1o@blog.com', '742.673.517-77'),
('209.910.815-51', 'Milka Gundrey', '505 Alpine Crossing', '52 4545-5860', '1961/07/22', 'mgundrey1p@ovh.net', '441.093.495-58'),
('007.489.656-87', 'Bayard Mullins', '98934 Butternut Hill', '63 31437-9437', '1987/11/02', 'bmullins1q@friendfeed.com', '868.545.070-28'),
('017.480.515-40', 'Fayette Parcells', '4361 Eastwood Parkway', '65 5830-1169', '1985/01/30', 'fparcells1r@reverbnation.com', '446.836.849-32'),
('539.185.835-06', 'Adam Omar', '933 Glacier Hill Point', '19 2503-0816', '1972/06/27', 'aomar1s@pcworld.com', '805.462.760-01'),
('281.543.528-14', 'Melly Laughrey', '60010 Westport Center', '53 2553-8151', '1967/02/01', 'mlaughrey1t@youku.com', '006.426.753-34'),
('156.543.017-64', 'Brenden Tregidga', '585 Muir Avenue', '03 7323-9201', '1971/03/19', 'btregidga1u@cpanel.net', '442.763.048-82'),
('594.599.469-38', 'Susie De Filippis', '3 Ilene Drive', '97 45341-9988', '1990/04/13', 'sde1v@ow.ly', '237.179.782-68'),
('771.357.866-12', 'Faulkner Falloon', '4296 Morning Terrace', '34 75051-1842', '1988/10/08', 'ffalloon1w@wix.com', '750.304.004-88'),
('340.551.313-11', 'Karena Winterbotham', '837 Summerview Alley', '46 25926-3567', '1972/06/15', 'kwinterbotham1x@biblegateway.com', '008.253.290-46'),
('094.653.417-41', 'Giovanna Peterkin', '7 Northridge Way', '53 6204-7432', '1982/08/18', 'gpeterkin1y@samsung.com', '318.944.059-81'),
('606.121.069-16', 'Philippine Furlonge', '97 Kedzie Court', '20 0846-1542', '1968/01/25', 'pfurlonge1z@oracle.com', '722.765.786-52'),
('958.604.534-11', 'Carmine McCulley', '764 Moose Junction', '36 89671-3479', '1980/09/11', 'cmcculley20@independent.co.uk', '526.717.236-39'),
('762.283.316-24', 'Teri Camplin', '46 Debra Alley', '06 0890-5110', '1987/07/16', 'tcamplin21@dot.gov', '441.093.495-58'),
('976.005.794-92', 'Zared Kipling', '0620 Paget Place', '70 1756-1133', '1981/05/28', 'zkipling22@networkadvertising.org', '532.238.389-00'),
('398.785.073-56', 'Beck Jacox', '79759 Shasta Court', '83 84897-2331', '1976/03/31', 'bjacox23@nsw.gov.au', '868.545.070-28'),
('913.016.459-65', 'Boyce Zywicki', '17 Roth Parkway', '17 68615-8923', '1986/02/14', 'bzywicki24@xing.com', '955.674.466-67'),
('082.905.302-44', 'Harald Shave', '0 Fordem Alley', '30 30529-8537', '1965/09/08', 'hshave25@google.co.jp', '444.862.886-52'),
('811.904.260-87', 'Odo Dorset', '7414 Schiller Avenue', '07 9498-8449', '1972/11/15', 'odorset26@toplist.cz', '281.505.763-16'),
('830.243.415-13', 'Kin Brewitt', '5019 Killdeer Center', '77 17648-0687', '1985/11/16', 'kbrewitt27@smh.com.au', '369.186.788-27'),
('484.246.958-19', 'Garrick Couser', '38 Bultman Drive', '98 55203-0717', '1989/12/25', 'gcouser28@irs.gov', '341.457.395-88'),
('994.995.422-57', 'Maren Byrth', '2234 Killdeer Parkway', '07 59629-3718', '1977/07/02', 'mbyrth29@illinois.edu', '444.862.886-52'),
('651.008.495-48', 'Naomi Moss', '4 Mallard Alley', '12 9122-5898', '1982/11/14', 'nmoss2a@wordpress.org', '531.007.052-94'),
('828.011.582-21', 'Hamish Kayley', '50 Basil Circle', '10 87439-5239', '1978/07/02', 'hkayley2b@delicious.com', '144.107.113-27'),
('769.653.270-33', 'Teddy Hunter', '30486 Del Sol Lane', '00 16544-3477', '1976/07/25', 'thunter2c@qq.com', '461.456.100-93'),
('627.471.399-68', 'Sylvester Lennox', '6621 Mallory Drive', '59 68189-6370', '1972/01/22', 'slennox2d@intel.com', '318.944.059-81'),
('237.925.897-45', 'Bunnie Dellow', '044 Cardinal Circle', '90 7701-4713', '1961/09/25', 'bdellow2e@macromedia.com', '061.376.881-44'),
('701.046.551-76', 'Austina Waslin', '60 Emmet Drive', '08 80058-3156', '1963/07/17', 'awaslin2f@jalbum.net', '363.253.921-42'),
('631.983.820-26', 'Lizzie Dot', '37604 David Drive', '54 15065-2017', '1967/01/02', 'ldot2g@nbcnews.com', '554.066.740-55'),
('873.105.687-50', 'Jonah Stooders', '71 Arizona Road', '81 3068-2906', '1982/07/19', 'jstooders2h@cargocollective.com', '554.066.740-55'),
('149.529.450-82', 'Sully Haacker', '6173 Lukken Park', '99 13300-6608', '1968/11/04', 'shaacker2i@kickstarter.com', '166.165.606-14'),
('220.768.346-97', 'Maible Scipsey', '0 Sullivan Way', '51 6808-1309', '1972/11/02', 'mscipsey2j@nih.gov', '722.765.786-52'),
('975.498.371-51', 'Frederico Gambrell', '0516 Express Road', '36 4778-6576', '1974/06/30', 'fgambrell2k@mashable.com', '492.550.597-38'),
('242.387.948-12', 'Bibbie Jayes', '60 Granby Plaza', '59 7246-4725', '1987/12/20', 'bjayes2l@phoca.cz', '264.822.047-58'),
('073.667.551-00', 'Danya Skuce', '3 Mesta Crossing', '64 69160-7154', '1983/04/24', 'dskuce2m@mysql.com', '531.571.851-68'),
('254.338.273-23', 'Pennie Johnston', '316 Hoepker Road', '61 0991-2531', '1989/12/24', 'pjohnston2n@nyu.edu', '369.186.788-27'),
('000.755.590-92', 'Zita Pentony', '8 Northland Circle', '63 7251-7879', '1972/03/23', 'zpentony2o@seesaa.net', '787.833.224-53'),
('749.506.194-82', 'Clarette Matysik', '8671 Swallow Alley', '30 4030-8910', '1969/05/12', 'cmatysik2p@npr.org', '276.610.118-24'),
('040.401.785-26', 'Gerrie Bruckman', '30 Bartelt Road', '48 5025-7379', '1986/12/25', 'gbruckman2q@t-online.de', '061.376.881-44'),
('736.484.920-20', 'Marion Hymers', '852 Vahlen Trail', '67 76851-6306', '1964/12/16', 'mhymers2r@istockphoto.com', '360.485.474-56'),
('820.150.524-47', 'Umeko Voyce', '3229 Main Way', '36 23062-9605', '1977/05/19', 'uvoyce2s@exblog.jp', '369.186.788-27'),
('102.574.757-79', 'Isabeau Jansey', '4311 Novick Parkway', '63 5460-4742', '1966/07/03', 'ijansey2t@loc.gov', '734.497.094-21'),
('193.480.716-83', 'Jena d'' Elboux', '53596 2nd Trail', '05 49822-1715', '1980/10/08', 'jd2u@rambler.ru', '531.007.052-94'),
('083.735.639-09', 'Rafaello Lucia', '01 Lake View Alley', '90 19740-9659', '1977/06/11', 'rlucia2v@gmpg.org', '360.485.474-56'),
('240.602.349-59', 'Carce Tocher', '551 Summit Center', '92 73629-5074', '1985/06/14', 'ctocher2w@yandex.ru', '144.107.113-27'),
('419.698.721-71', 'Fina Gelletly', '01529 Hoepker Circle', '90 7746-7942', '1981/09/08', 'fgelletly2x@storify.com', '712.861.332-39'),
('674.175.273-28', 'Charmane Sapey', '6409 Rigney Crossing', '74 1075-3687', '1989/08/12', 'csapey2y@webeden.co.uk', '402.097.132-05'),
('708.640.413-72', 'Karie Pettipher', '3 Mifflin Circle', '85 54848-7116', '1984/10/05', 'kpettipher2z@mtv.com', '734.497.094-21'),
('901.939.045-13', 'Floris Wortley', '6 Packers Junction', '46 0879-5275', '1985/04/29', 'fwortley30@arstechnica.com', '369.186.788-27'),
('525.851.862-52', 'Heindrick Tolomei', '828 Brentwood Center', '03 20469-8374', '1974/02/03', 'htolomei31@360.cn', '277.442.596-61'),
('535.643.965-80', 'Oralie Gioan', '1148 Mosinee Crossing', '03 32440-6404', '1966/08/01', 'ogioan32@theguardian.com', '959.307.874-14'),
('180.309.884-22', 'Moira Ughelli', '611 Northwestern Pass', '60 9877-0113', '1978/07/15', 'mughelli33@europa.eu', '779.201.171-12'),
('403.353.893-26', 'Rowen Habbershon', '240 Ludington Plaza', '56 05450-6197', '1976/04/27', 'rhabbershon34@amazon.co.uk', '031.815.041-85'),
('310.261.012-88', 'Stefania Metcalf', '51917 Myrtle Road', '23 2265-3526', '1975/03/19', 'smetcalf35@wunderground.com', '779.201.171-12'),
('183.482.449-56', 'Kaitlin Riquet', '22048 Hayes Plaza', '93 28551-1153', '1964/02/18', 'kriquet36@archive.org', '541.421.625-79'),
('474.231.051-64', 'Robin Trimble', '16742 Miller Lane', '43 08774-9608', '1969/05/29', 'rtrimble37@apple.com', '723.823.320-68'),
('437.188.139-91', 'Madonna Yakutin', '07195 Fairfield Parkway', '89 24853-5858', '1966/11/19', 'myakutin38@springer.com', '531.571.851-68'),
('677.599.161-18', 'Barrett Hunnisett', '35240 Autumn Leaf Crossing', '15 7760-7866', '1973/02/08', 'bhunnisett39@51.la', '982.141.117-21'),
('976.205.328-25', 'Clarence Crothers', '134 Mandrake Plaza', '70 6189-5810', '1988/12/22', 'ccrothers3a@youtu.be', '839.385.633-33'),
('770.327.220-20', 'La verne Taffie', '93 Thackeray Park', '52 6070-5312', '1982/01/18', 'lverne3b@wordpress.com', '516.179.951-13');

insert into cartaocredito (numero, validade, fk_cliente_cpf) values 
('7650504435152195', '2023/10/21', '649.852.880-92'),
('5446795673541156', '2021/12/14', '957.783.120-41'),
('6671796397220832', '2023/04/22', '360.485.474-56'),
('4881852120028430', '2023/09/07', '227.096.607-44'),
('2967547147661786', '2023/02/22', '839.385.633-33'),
('0482171308138454', '2024/03/14', '005.981.956-22'),
('3152489765354858', '2022/02/18', '264.822.047-58'),
('1362860607509246', '2021/07/11', '532.238.389-00'),
('1541755373290146', '2020/10/05', '227.096.607-44'),
('0976294373169649', '2022/03/03', '166.165.606-14'),
('2797533066938307', '2023/04/03', '556.153.810-80'),
('2010258917784258', '2022/02/01', '492.550.597-38'),
('4955649653473582', '2021/04/04', '281.505.763-16'),
('2063865610594357', '2023/07/10', '340.253.322-86'),
('2229001894686654', '2024/03/09', '767.354.449-90'),
('6594023489766241', '2023/03/01', '533.842.589-85'),
('6844462255499223', '2022/02/17', '130.133.676-15'),
('6936089517182693', '2022/11/18', '363.253.921-42'),
('6724398425236347', '2021/03/28', '165.661.113-85'),
('0164673598729180', '2022/10/11', '340.253.322-86'),
('9897525037772614', '2021/01/30', '444.862.886-52'),
('3845576305677096', '2020/12/06', '442.763.048-82'),
('4756812480734259', '2020/10/13', '163.331.347-06'),
('9815404280091535', '2022/09/01', '805.462.760-01'),
('6949940454047607', '2023/11/29', '617.754.443-96'),
('4703769075447985', '2021/11/29', '166.165.606-14'),
('1026274905047007', '2020/10/15', '959.307.874-14'),
('3061871354719409', '2023/11/04', '005.981.956-22'),
('5872306631658736', '2024/04/16', '116.861.478-03'),
('4902003532432068', '2021/04/05', '868.545.070-28'),
('0935221815928757', '2020/06/27', '516.179.951-13'),
('9175006746796231', '2022/10/18', '277.442.596-61'),
('4108041900608682', '2021/11/12', '541.421.625-79'),
('4996199849118039', '2021/06/14', '541.421.625-79'),
('4568319087605057', '2023/10/18', '531.007.052-94'),
('3104103882536871', '2021/08/11', '556.153.810-80'),
('4453533484380790', '2021/02/20', '723.823.320-68'),
('0453877584894373', '2023/05/09', '745.156.491-93'),
('1756524900797452', '2024/03/26', '767.354.449-90'),
('0682109773312211', '2024/03/19', '165.661.113-85'),
('2028059561969208', '2023/09/17', '279.134.410-94'),
('3044120196052484', '2021/08/10', '461.456.100-93'),
('3430444922937210', '2020/09/06', '723.823.320-68'),
('8615432804922962', '2021/03/23', '677.261.522-10'),
('8329338762746285', '2024/04/28', '276.610.118-24'),
('9389088959916839', '2020/11/14', '369.186.788-27'),
('6969455266167842', '2024/04/02', '061.376.881-44'),
('7435851972902675', '2023/11/01', '437.730.798-93'),
('0491211659164531', '2023/07/06', '551.753.653-02'),
('5580844910364588', '2020/07/20', '363.253.921-42'),
('9492362727936404', '2023/05/23', '163.331.347-06'),
('2955320338850453', '2023/05/24', '281.505.763-16'),
('1232043003612781', '2021/07/15', '436.705.137-01'),
('5622829262463692', '2021/04/26', '289.191.196-40'),
('3018174180063807', '2023/10/29', '165.661.113-85'),
('8309827635854232', '2021/05/02', '787.833.224-53'),
('2366699909471691', '2023/12/31', '062.777.968-51'),
('6489738101432859', '2024/03/10', '461.456.100-93'),
('4153115332480122', '2021/08/29', '742.673.517-77'),
('3200340842759528', '2021/11/07', '629.635.572-68'),
('0963172344897072', '2022/05/01', '723.823.320-68'),
('4193191085622323', '2021/09/17', '966.791.837-13'),
('4352976952518447', '2021/06/15', '723.823.320-68'),
('3997000013664959', '2023/05/15', '959.307.874-14'),
('3523675564901481', '2021/04/30', '369.186.788-27'),
('5521400097401214', '2021/04/08', '575.521.610-37'),
('6289918798438792', '2022/05/07', '734.497.094-21'),
('9893075275598535', '2023/11/05', '162.835.688-45'),
('6811550540411180', '2022/08/31', '882.192.714-48'),
('5833108118259674', '2024/02/22', '767.354.449-90'),
('0439403837169317', '2021/08/19', '360.485.474-56'),
('4122341653444856', '2022/03/30', '779.201.171-12'),
('9737270542700318', '2022/10/20', '954.585.915-16'),
('2955958877692224', '2020/09/12', '237.179.782-68'),
('8710466254266035', '2021/02/21', '165.661.113-85'),
('7222878205849295', '2023/02/05', '957.783.120-41'),
('5058374835755802', '2021/10/13', '531.007.052-94'),
('7951743178126082', '2022/09/24', '363.253.921-42'),
('0148135643297101', '2022/12/03', '062.777.968-51'),
('7078385618969144', '2020/10/09', '556.153.810-80'),
('0229839898714884', '2022/09/11', '982.141.117-21'),
('9342049881153960', '2022/06/29', '551.753.653-02'),
('3986535013791794', '2020/06/19', '165.661.113-85'),
('1104382039013001', '2022/10/25', '712.055.970-34'),
('5337145720469545', '2021/05/26', '133.111.108-13'),
('8508864076999650', '2021/12/31', '742.673.517-77'),
('9740428006482150', '2020/12/20', '061.376.881-44'),
('4231827175694223', '2022/08/19', '750.304.004-88'),
('5591202357451503', '2020/07/04', '516.179.951-13'),
('0503597548816198', '2022/09/05', '750.304.004-88'),
('8348887936500108', '2024/02/04', '237.179.782-68'),
('0402042719480236', '2021/08/31', '276.610.118-24'),
('5793158292290620', '2020/09/07', '955.674.466-67'),
('5624157384542363', '2021/04/22', '633.420.255-81'),
('1726884670381448', '2020/06/24', '318.944.059-81'),
('3808797874774703', '2023/01/30', '722.765.786-52'),
('7631765943673066', '2021/08/16', '031.815.041-85'),
('1896190087283979', '2023/03/31', '277.442.596-61'),
('9373783468925556', '2024/01/08', '575.521.610-37'),
('8204992822231899', '2024/04/30', '787.833.224-53');

insert into pagamento (cod, pagamento_tipo, fk_cliente_cpf) values 
(434291, 0, '162.835.688-45'),
(785969, 1, '442.763.048-82'),
(365251, 1, '787.833.224-53'),
(759613, 0, '742.673.517-77'),
(495328, 0, '649.852.880-92'),
(291497, 1, '742.673.517-77'),
(316836, 1, '722.765.786-52'),
(439794, 1, '982.141.117-21'),
(127179, 0, '363.253.921-42'),
(282294, 1, '787.833.224-53'),
(335492, 0, '031.815.041-85'),
(262164, 0, '369.186.788-27'),
(909038, 0, '360.485.474-56'),
(259139, 0, '116.861.478-03'),
(885916, 1, '442.763.048-82'),
(818352, 0, '966.791.837-13'),
(88644, 1, '690.698.534-49'),
(662752, 0, '340.253.322-86'),
(400138, 0, '441.093.495-58'),
(425165, 0, '629.635.572-68'),
(258324, 0, '556.153.810-80'),
(639191, 1, '062.777.968-51'),
(640379, 0, '954.585.915-16'),
(798061, 0, '461.456.100-93'),
(135133, 0, '531.007.052-94'),
(542089, 1, '369.186.788-27'),
(987823, 0, '237.179.782-68'),
(258628, 1, '767.354.449-90'),
(835795, 1, '677.261.522-10'),
(419263, 1, '779.201.171-12'),
(875461, 0, '712.055.970-34'),
(278159, 0, '062.777.968-51'),
(487445, 0, '360.485.474-56'),
(584535, 1, '531.007.052-94'),
(584326, 0, '551.753.653-02'),
(386922, 1, '162.835.688-45'),
(660067, 1, '341.457.395-88'),
(762318, 0, '166.165.606-14'),
(402904, 0, '264.822.047-58'),
(863002, 0, '144.107.113-27'),
(691266, 1, '363.253.921-42'),
(925221, 0, '439.926.952-83'),
(740545, 1, '133.111.108-13'),
(121190, 1, '166.165.606-14'),
(829230, 1, '281.505.763-16'),
(68292, 0, '276.610.118-24'),
(36563, 0, '461.456.100-93'),
(562955, 0, '712.861.332-39'),
(952566, 0, '264.822.047-58'),
(212224, 0, '839.385.633-33');

insert into manutencao (datainicio, datafim, descricao, fk_veiculo_placa, fk_gerente_idg) values 
('2017/07/05', '2017/07/11', 'Nulla nisl. Nunc nisl.', 'ESA9229', 4),
('2016/09/18', '2016/09/23', 'Maecenas pulvinar lobortis est.', 'AXV8242', 3),
('2018/05/06', '2018/05/27', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', 'OSH6282', 2),
('2017/08/17', '2017/08/29', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'QRV9560', 3),
('2018/03/09', '2018/03/22', 'Cras pellentesque volutpat dui.', 'EJG0751', 2),
('2016/11/22', '2016/12/16', 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 'BQW2696', 1),
('2018/02/23', '2018/03/12', 'Nulla facilisi.', 'BDZ2271', 1),
('2018/08/30', '2018/09/28', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', 'DST8994', 1),
('2016/11/02', '2016/11/05', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'ZUF6442', 6),
('2018/06/30', '2018/07/17', 'Curabitur convallis.', 'WKP5966', 3),
('2017/02/05', '2017/02/22', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'ONZ9142', 5),
('2019/04/20', '2019/04/26', 'Nullam molestie nibh in lectus.', 'ESA9229', 3),
('2018/03/05', '2018/03/24', 'Curabitur at ipsum ac tellus semper interdum.', 'QTJ7481', 3),
('2018/04/13', '2018/04/26', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 'VXF0628', 6),
('2018/01/08', '2018/01/24', 'Morbi quis tortor id nulla ultrices aliquet.', 'TLH1957', 6),
('2018/09/08', '2018/09/28', 'Nullam varius. Nulla facilisi.', 'AXV8242', 5),
('2016/10/09', '2016/10/28', 'Donec dapibus. Duis at velit eu est congue elementum.', 'CRD7250', 1),
('2017/03/27', '2017/04/19', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 'HKC2075', 3),
('2016/09/07', '2016/09/28', 'Integer a nibh.', 'ZUF6442', 2),
('2018/03/10', '2018/03/25', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', 'RIG0081', 1),
('2018/02/02', '2018/02/06', 'Suspendisse accumsan tortor quis turpis. Sed ante.', 'LIQ6615', 1),
('2018/01/30', '2018/02/21', 'In quis justo.', 'HUF0630', 4),
('2017/11/01', '2017/11/09', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices.', 'FAK3425', 3),
('2019/01/19', '2019/01/30', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'HIS9889', 1),
('2019/04/29', '2019/05/27', 'Duis at velit eu est congue elementum.', 'QTJ7481', 2),
('2019/01/30', '2019/02/20', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', 'HIS9889', 4),
('2016/10/03', '2016/10/29', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'OSH6282', 2),
('2017/05/28', '2017/06/21', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'QRV9560', 2),
('2019/06/13', '2019/06/21', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', 'MUQ1793', 2),
('2018/02/13', '2018/03/12', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'LVQ2864', 3);

insert into operacao (cod, data, valor, operacao_tipo, fk_gerente_idg) values 
(1, '2018/02/21', 38898, 0, 4),
(2, '2018/05/07', 149690, 1, 6),
(3, '2016/11/05', 113785, 0, 3),
(4, '2016/07/02', 148920, 1, 2),
(5, '2016/08/01', 198627, 0, 6),
(6, '2017/09/12', 93815, 0, 5),
(7, '2016/06/20', 151507, 1, 4),
(8, '2015/09/07', 38440, 1, 3);

insert into negocia (fk_veiculo_placa, fk_operacao_cod) values 
('LBP8889', 7),
('DTH4206', 2),
('DST8994', 2),
('BDZ2271', 7),
('WCU7435', 7),
('EJG0751', 2);

insert into transferencia_veiculo_filial_gerente (fk_veiculo_placa, fk_filial_id_1, fk_filial_id_2, fk_gerente_idg) values 
('LBP8889', 6, 1, 1),
('TYC5213', 2, 3, 2),
('VXF0628', 1, 4, 4),
('QRV9560', 5, 4, 5),
('RDV7473', 2, 6, 6),
('BOD6456', 3, 2, 2),
('ZUF6442', 3, 4, 3),
('QRV9560', 6, 4, 6),
('VXF0628', 3, 4, 4),
('IGV8025', 5, 3, 5),
('HUF0630', 6, 2, 6),
('RDV7473', 3, 6, 6),
('HIS9889', 4, 6, 4),
('RIG0081', 6, 1, 6),
('ESA9229', 2, 6, 6),
('ZUF6442', 6, 4, 6),
('WCU7435', 6, 1, 6),
('OSH6282', 5, 2, 2);

insert into locacao_reserva (datainicio, datafim, dataretirada, datadevolucao, valor, fk_cartaocredito_numero, fk_veiculo_placa, fk_funcionario_id, fk_pagamento_cod) values 
('2017/10/14', '2017/11/07', '2017/11/04', '2017/11/05', 591, 9342049881153960, 'DST8994', 16, 660067),
('2018/12/28', '2019/01/27', '2019/01/04', '2019/01/27', 1758, 4881852120028430, 'WCU7435', 1, 740545),
('2018/02/10', '2018/02/22', '2018/02/18', '2018/02/20', 1634, 9737270542700318, 'QTJ7481', 11, 759613),
('2017/08/09', '2017/09/03', '2017/08/22', '2017/08/23', 1241, 7631765943673066, 'LBP8889', 16, 400138),
('2018/11/05', '2018/11/16', '2018/11/13', '2018/11/13', 950, 3018174180063807, 'QWX8043', 16, 36563),
('2018/10/18', '2018/11/11', '2018/10/31', '2018/11/01', 744, 6969455266167842, 'HUF0630', 18, 885916),
('2017/12/29', '2018/01/17', '2018/01/07', '2018/01/10', 645, 3808797874774703, 'LFD5129', 9, 36563),
('2018/04/27', '2018/05/24', '2018/05/22', '2018/05/24', 1824, 8615432804922962, 'DTH4206', 10, 88644),
('2017/07/18', '2017/08/12', '2017/08/01', '2017/08/11', 1738, 6969455266167842, 'ONZ9142', 12, 885916),
('2017/11/21', '2017/12/05', '2017/11/26', '2017/12/05', 2207, '0439403837169317', 'TLH1957', 11, 952566),
('2018/11/21', '2018/12/15', '2018/11/22', '2018/12/02', 1734, '2797533066938307', 'EKB8886', 18, 829230),
('2018/09/25', '2018/10/12', '2018/10/10', '2018/10/12', 3379, '3044120196052484', 'QRV9560', 10, 829230),
('2018/09/21', '2018/10/01', '2018/09/30', '2018/09/30', 3089, '6289918798438792', 'TLH1957', 9, 639191),
('2017/12/21', '2017/12/27', '2017/12/27', '2017/12/27', 2525, '9342049881153960', 'TLH1957', 16, 759613),
('2018/09/29', '2018/10/15', '2018/10/07', '2018/10/07', 431, '6724398425236347', 'DTH4206', 8, 135133),
('2017/09/27', '2017/10/12', '2017/09/30', '2017/10/11', 3006, '3845576305677096', 'AXV8242', 20, 400138),
('2019/01/09', '2019/01/14', '2019/01/12', '2019/01/14', 1740, '5622829262463692', 'BQW2696', 16, 127179),
('2018/09/13', '2018/09/21', '2018/09/16', '2018/09/18', 3148, '3986535013791794', 'EJG0751', 15, 262164),
('2018/07/06', '2018/07/31', '2018/07/14', '2018/07/22', 2752, '3044120196052484', 'VXF0628', 1, 829230),
('2018/04/09', '2018/04/19', '2018/04/12', '2018/04/16', 1195, '3523675564901481', 'VXF0628', 11, 278159),
('2018/04/05', '2018/04/24', '2018/04/08', '2018/04/14', 2778, '4153115332480122', 'FWR5055', 1, 439794),
('2018/10/05', '2018/10/30', '2018/10/27', '2018/10/27', 367, '4352976952518447', 'RIG0081', 8, 400138),
('2018/04/15', '2018/05/08', '2018/04/30', '2018/05/05', 2497, '2955320338850453', 'BOD6456', 8, 121190),
('2017/12/07', '2017/12/13', '2017/12/08', '2017/12/10', 2885, '9893075275598535', 'WKP5966', 21, 386922),
('2018/01/21', '2018/02/14', '2018/02/02', '2018/02/12', 1830, '2229001894686654', 'QTJ7481', 19, 88644),
('2017/10/19', '2017/10/25', '2017/10/20', '2017/10/22', 874, '0164673598729180', 'QWX8043', 4, 818352),
('2019/01/31', '2019/02/17', '2019/02/07', '2019/02/15', 1498, '3200340842759528', 'EXM4840', 6, 798061),
('2017/07/03', '2017/07/12', '2017/07/06', '2017/07/11', 1282, '4153115332480122', 'VXF0628', 7, 660067),
('2018/01/10', '2018/01/22', '2018/01/22', '2018/01/22', 2720, '2229001894686654', 'OSH6282', 8, 135133),
('2017/09/28', '2017/10/15', '2017/10/02', '2017/10/08', 2431, '6969455266167842', 'QTJ7481', 12, 829230),
('2018/08/25', '2018/09/12', '2018/09/04', '2018/09/05', 3088, '9737270542700318', 'BOD6456', 10, 68292),
('2019/01/07', '2019/01/12', '2019/01/09', '2019/01/10', 104, '0148135643297101', 'FWR5055', 14, 542089),
('2018/02/14', '2018/03/02', '2018/02/16', '2018/02/28', 1268, '3986535013791794', 'IGV8025', 5, 584326),
('2017/11/07', '2017/11/14', '2017/11/07', '2017/11/13', 2467, '4756812480734259', 'OSH6282', 5, 662752),
('2018/12/13', '2018/12/18', '2018/12/17', '2018/12/18', 2438, '6724398425236347', 'ZUF6442', 13, 863002),
('2019/01/22', '2019/02/20', '2019/01/23', '2019/02/14', 2540, '4231827175694223', 'FWR5055', 4, 818352),
('2018/06/26', '2018/07/03', '2018/06/30', '2018/06/30', 3403, '5833108118259674', 'ZUF6442', 12, 487445),
('2018/11/11', '2018/11/15', '2018/11/12', '2018/11/12', 1310, '7650504435152195', 'QTJ7481', 8, 121190),
('2018/07/13', '2018/07/25', '2018/07/19', '2018/07/20', 472, '4231827175694223', 'HIS9889', 11, 952566),
('2018/11/27', '2018/11/30', '2018/11/28', '2018/11/29', 656, '2955958877692224', 'TYC5213', 10, 88644),
('2018/11/01', '2018/11/28', '2018/11/26', '2018/11/26', 2257, '9815404280091535', 'BOD6456', 12, 335492),
('2018/06/24', '2018/07/05', '2018/07/03', '2018/07/04', 3966, '0682109773312211', 'TYC5213', 21, 88644),
('2018/10/20', '2018/11/03', '2018/10/29', '2018/11/02', 2886, '8710466254266035', 'VBQ6295', 3, 258628),
('2018/02/05', '2018/03/06', '2018/03/04', '2018/03/05', 3762, '1362860607509246', 'QZC4039', 2, 258324),
('2018/08/07', '2018/08/16', '2018/08/10', '2018/08/15', 582, '6936089517182693', 'CRD7250', 21, 135133),
('2018/09/20', '2018/09/23', '2018/09/22', '2018/09/22', 1588, '3808797874774703', 'LIQ6615', 6, 875461),
('2019/02/14', '2019/03/11', '2019/03/03', '2019/03/09', 769, '9737270542700318', 'EJG0751', 21, 987823),
('2018/04/19', '2018/04/29', '2018/04/28', '2018/04/28', 1763, '8615432804922962', 'OSH6282', 16, 316836),
('2019/02/11', '2019/03/04', '2019/02/14', '2019/02/24', 1966, '3430444922937210', 'KWE3657', 7, 542089),
('2018/12/29', '2019/01/07', '2018/12/29', '2019/01/01', 442, '6671796397220832', 'RIG0081', 4, 386922),
('2018/01/23', '2018/02/11', '2018/02/11', '2018/02/11', 3414, '4453533484380790', 'VBQ6295', 14, 425165),
('2018/08/25', '2018/09/13', '2018/08/26', '2018/08/31', 1794, '5591202357451503', 'EKB8886', 4, 952566),
('2018/04/10', '2018/04/19', '2018/04/15', '2018/04/17', 3208, '3044120196052484', 'UEI7297', 9, 909038),
('2017/09/14', '2017/09/29', '2017/09/28', '2017/09/28', 3726, '7650504435152195', 'LBP8889', 18, 829230),
('2017/12/23', '2018/01/03', '2017/12/28', '2017/12/29', 3234, '1541755373290146', 'ZUF6442', 20, 495328),
('2018/11/18', '2018/12/18', '2018/12/09', '2018/12/12', 1649, '3808797874774703', 'BOD6456', 10, 262164),
('2019/03/06', '2019/03/20', '2019/03/19', '2019/03/20', 681, '4996199849118039', 'LVQ2864', 6, 258324),
('2018/10/18', '2018/11/03', '2018/10/24', '2018/10/28', 3174, '1896190087283979', 'RDV7473', 10, 829230),
('2019/01/11', '2019/02/06', '2019/01/15', '2019/02/06', 2316, '2797533066938307', 'ESA9229', 2, 562955),
('2018/06/13', '2018/07/05', '2018/06/15', '2018/06/30', 1021, '3061871354719409', 'BDZ2271', 2, 829230),
('2018/06/22', '2018/07/17', '2018/06/23', '2018/06/30', 1616, '3845576305677096', 'VXF0628', 10, 262164),
('2017/07/31', '2017/08/28', '2017/08/09', '2017/08/11', 1122, '3044120196052484', 'KWE3657', 8, 365251),
('2018/01/20', '2018/02/12', '2018/02/09', '2018/02/09', 863, '2797533066938307', 'VXF0628', 11, 584326),
('2018/02/16', '2018/03/02', '2018/02/17', '2018/02/27', 1469, '7951743178126082', 'TLH1957', 18, 212224),
('2017/09/23', '2017/10/20', '2017/10/01', '2017/10/18', 1569, '1362860607509246', 'KWE3657', 6, 434291),
('2017/10/24', '2017/11/21', '2017/10/29', '2017/11/08', 2029, '5337145720469545', 'MUQ1793', 13, 487445),
('2017/12/05', '2017/12/29', '2017/12/24', '2017/12/27', 1181, '0963172344897072', 'BDZ2271', 9, 863002),
('2018/11/09', '2018/11/22', '2018/11/14', '2018/11/18', 2655, '0148135643297101', 'QZC4039', 5, 127179),
('2018/11/05', '2018/11/19', '2018/11/14', '2018/11/15', 936, '4756812480734259', 'VBQ6295', 7, 419263),
('2018/03/05', '2018/03/25', '2018/03/14', '2018/03/18', 936, '6289918798438792', 'WCU7435', 15, 762318),
('2017/07/09', '2017/08/07', '2017/08/04', '2017/08/07', 2173, '3845576305677096', 'EJG0751', 8, 425165),
('2017/09/06', '2017/09/23', '2017/09/17', '2017/09/23', 3798, '4193191085622323', 'FWR5055', 1, 259139),
('2019/03/16', '2019/04/08', '2019/03/16', '2019/04/05', 2763, '5624157384542363', 'KWE3657', 20, 660067),
('2018/08/07', '2018/08/26', '2018/08/08', '2018/08/21', 2808, '7631765943673066', 'LVQ2864', 8, 885916),
('2019/03/06', '2019/03/30', '2019/03/22', '2019/03/25', 1767, '6844462255499223', 'MUQ1793', 11, 584535),
('2017/06/21', '2017/07/04', '2017/06/29', '2017/07/02', 1358, '4453533484380790', 'QWX8043', 3, 909038),
('2018/03/07', '2018/03/20', '2018/03/07', '2018/03/14', 1489, '5833108118259674', 'TLH1957', 11, 662752),
('2018/10/02', '2018/10/19', '2018/10/05', '2018/10/17', 471, '0482171308138454', 'VXF0628', 18, 639191),
('2019/01/20', '2019/02/17', '2019/01/23', '2019/01/27', 2796, '3061871354719409', 'WCU7435', 10, 386922),
('2018/05/25', '2018/05/29', '2018/05/29', '2018/05/29', 2797, '9893075275598535', 'RDV7473', 11, 762318),
('2018/12/10', '2018/12/20', '2018/12/17', '2018/12/19', 2534, '4703769075447985', 'DST8994', 6, 335492),
('2017/09/22', '2017/10/15', '2017/09/29', '2017/10/11', 628, '5591202357451503', 'BOD6456', 3, 335492),
('2018/02/04', '2018/02/17', '2018/02/09', '2018/02/11', 1944, '4122341653444856', 'CRD7250', 18, 365251),
('2017/12/23', '2018/01/09', '2018/01/05', '2018/01/07', 750, '4122341653444856', 'WCU7435', 19, 135133),
('2017/12/17', '2018/01/14', '2018/01/14', '2018/01/14', 452, '6724398425236347', 'BQW2696', 2, 258628),
('2018/03/04', '2018/03/11', '2018/03/04', '2018/03/09', 3492, '1541755373290146', 'BQW2696', 3, 909038),
('2018/08/14', '2018/08/31', '2018/08/21', '2018/08/25', 2628, '3152489765354858', 'VXF0628', 12, 127179),
('2018/03/08', '2018/03/17', '2018/03/16', '2018/03/17', 3020, '0453877584894373', 'DTH4206', 11, 316836),
('2019/02/08', '2019/02/13', '2019/02/08', '2019/02/11', 3051, '6724398425236347', 'BDZ2271', 1, 640379),
('2017/11/16', '2017/12/16', '2017/12/01', '2017/12/04', 634, '6949940454047607', 'DTH4206', 14, 909038),
('2018/10/15', '2018/11/02', '2018/10/28', '2018/10/30', 3316, '2955958877692224', 'EXM4840', 15, 68292),
('2019/01/15', '2019/02/09', '2019/02/04', '2019/02/07', 3236, '5833108118259674', 'BOD6456', 5, 495328),
('2017/07/07', '2017/07/19', '2017/07/12', '2017/07/18', 477, '4352976952518447', 'EJG0751', 12, 885916),
('2018/05/08', '2018/05/21', '2018/05/11', '2018/05/16', 3488, '7650504435152195', 'QRV9560', 8, 952566),
('2019/03/10', '2019/03/16', '2019/03/16', '2019/03/16', 210, '6594023489766241', 'DTH4206', 7, 863002),
('2018/06/30', '2018/07/25', '2018/07/14', '2018/07/22', 2423, '7435851972902675', 'RDV7473', 1, 335492),
('2018/07/12', '2018/07/20', '2018/07/16', '2018/07/17', 2510, '8508864076999650', 'LBP8889', 5, 259139),
('2018/12/06', '2018/12/29', '2018/12/11', '2018/12/11', 2538, '3018174180063807', 'EKB8886', 12, 316836),
('2017/09/30', '2017/10/03', '2017/09/30', '2017/10/01', 2153, '9175006746796231', 'HIS9889', 19, 542089),
('2019/03/12', '2019/04/11', '2019/03/21', '2019/04/11', 2210, '6811550540411180', 'QWX8043', 15, 400138),
('2018/02/25', '2018/03/01', '2018/02/27', '2018/03/01', 2474, '3523675564901481', 'QZC4039', 1, 402904),
('2018/08/13', '2018/08/28', '2018/08/20', '2018/08/26', 930, '2967547147661786', 'LVQ2864', 4, 402904),
('2017/08/22', '2017/09/05', '2017/08/26', '2017/08/28', 1670, '4122341653444856', 'RIG0081', 12, 798061),
('2017/11/03', '2017/11/22', '2017/11/22', '2017/11/22', 2364, '0491211659164531', 'RIG0081', 3, 425165),
('2018/02/18', '2018/02/25', '2018/02/19', '2018/02/20', 2632, '1726884670381448', 'TYC5213', 9, 365251),
('2018/10/15', '2018/11/02', '2018/11/01', '2018/11/02', 2159, '6671796397220832', 'BOD6456', 2, 584326),
('2018/07/13', '2018/08/07', '2018/07/30', '2018/07/30', 1276, '6289918798438792', 'HIS9889', 15, 785969),
('2018/03/13', '2018/03/26', '2018/03/17', '2018/03/21', 1378, '8710466254266035', 'QWX8043', 1, 291497),
('2018/04/08', '2018/04/15', '2018/04/13', '2018/04/14', 3994, '8204992822231899', 'IGV8025', 8, 987823),
('2018/07/04', '2018/07/20', '2018/07/09', '2018/07/18', 127, '1541755373290146', 'VXF0628', 6, 584326),
('2017/12/14', '2018/01/08', '2017/12/24', '2018/01/07', 3686, '3523675564901481', 'VBQ6295', 18, 316836),
('2018/01/18', '2018/01/29', '2018/01/27', '2018/01/29', 2914, '3986535013791794', 'VXF0628', 14, 762318),
('2017/10/15', '2017/11/03', '2017/10/26', '2017/10/26', 3951, '1756524900797452', 'HIS9889', 19, 562955),
('2018/08/24', '2018/09/03', '2018/09/01', '2018/09/03', 638, '3997000013664959', 'QTJ7481', 16, 419263),
('2019/03/04', '2019/04/03', '2019/03/07', '2019/03/28', 1323, '7078385618969144', 'TLH1957', 17, 639191),
('2018/05/17', '2018/06/03', '2018/05/31', '2018/06/02', 1516, '3044120196052484', 'IGV8025', 3, 291497),
('2019/02/11', '2019/02/19', '2019/02/12', '2019/02/16', 335, '3986535013791794', 'FAK3425', 9, 762318),
('2017/08/22', '2017/09/17', '2017/09/10', '2017/09/17', 3661, '5793158292290620', 'CRD7250', 16, 639191),
('2018/06/12', '2018/07/07', '2018/06/30', '2018/07/01', 3941, '6936089517182693', 'FAK3425', 19, 278159),
('2017/08/30', '2017/09/20', '2017/09/12', '2017/09/15', 3989, '2366699909471691', 'QWX8043', 9, 909038),
('2017/09/01', '2017/09/07', '2017/09/05', '2017/09/07', 2590, '6969455266167842', 'FAK3425', 9, 762318),
('2018/04/30', '2018/05/11', '2018/04/30', '2018/05/10', 633, '4902003532432068', 'LBP8889', 12, 542089),
('2018/03/02', '2018/03/24', '2018/03/07', '2018/03/17', 1431, '9815404280091535', 'TLH1957', 1, 121190),
('2018/06/26', '2018/07/26', '2018/07/02', '2018/07/18', 2475, '9342049881153960', 'YAX7488', 10, 762318),
('2018/08/24', '2018/09/18', '2018/08/28', '2018/09/02', 2970, '7222878205849295', 'BQW2696', 7, 212224),
('2018/07/04', '2018/07/28', '2018/07/12', '2018/07/13', 681, '1232043003612781', 'KWE3657', 13, 495328),
('2017/09/11', '2017/10/04', '2017/09/25', '2017/09/25', 2835, '6724398425236347', 'ONZ9142', 9, 386922),
('2017/12/14', '2018/01/06', '2018/01/04', '2018/01/05', 3815, '0482171308138454', 'WKP5966', 11, 660067),
('2018/04/30', '2018/05/15', '2018/05/08', '2018/05/15', 2771, '9175006746796231', 'LFD5129', 20, 987823),
('2017/08/06', '2017/08/22', '2017/08/07', '2017/08/14', 1041, '7650504435152195', 'BQW2696', 15, 439794),
('2017/09/04', '2017/09/12', '2017/09/11', '2017/09/12', 3826, '0976294373169649', 'HIS9889', 19, 439794),
('2018/08/20', '2018/09/17', '2018/08/31', '2018/09/16', 2405, '2028059561969208', 'LFD5129', 18, 291497),
('2017/08/19', '2017/09/16', '2017/08/21', '2017/09/09', 1034, '5580844910364588', 'RDV7473', 4, 909038),
('2018/06/26', '2018/07/17', '2018/06/26', '2018/07/08', 3273, '2955958877692224', 'KWE3657', 6, 400138),
('2018/07/19', '2018/08/04', '2018/08/01', '2018/08/03', 1297, '0229839898714884', 'CRD7250', 10, 36563),
('2018/06/25', '2018/07/22', '2018/07/02', '2018/07/06', 3929, '0963172344897072', 'BOD6456', 6, 121190),
('2018/11/02', '2018/11/17', '2018/11/04', '2018/11/14', 2271, '6949940454047607', 'LBP8889', 10, 952566),
('2018/10/15', '2018/11/11', '2018/11/02', '2018/11/09', 2759, '1362860607509246', 'BOD6456', 15, 68292),
('2019/01/06', '2019/02/05', '2019/01/28', '2019/02/03', 772, '6289918798438792', 'TLH1957', 9, 662752),
('2018/01/09', '2018/02/04', '2018/01/14', '2018/01/16', 3995, '3044120196052484', 'MUQ1793', 18, 640379),
('2018/03/30', '2018/04/08', '2018/04/04', '2018/04/05', 3782, '7435851972902675', 'LVQ2864', 17, 88644),
('2018/08/13', '2018/08/22', '2018/08/22', '2018/08/22', 3604, '2955958877692224', 'DST8994', 11, 829230),
('2018/07/23', '2018/08/04', '2018/07/23', '2018/07/26', 435, '0482171308138454', 'HKC2075', 6, 952566),
('2018/02/02', '2018/02/26', '2018/02/25', '2018/02/25', 3646, '8329338762746285', 'HKC2075', 15, 36563),
('2017/08/19', '2017/08/27', '2017/08/24', '2017/08/27', 2921, '1896190087283979', 'TLH1957', 10, 88644),
('2018/04/13', '2018/04/23', '2018/04/19', '2018/04/20', 2254, '2797533066938307', 'IGV8025', 10, 316836),
('2017/12/23', '2018/01/21', '2018/01/14', '2018/01/14', 1543, '6594023489766241', 'QRV9560', 3, 127179),
('2018/05/23', '2018/06/01', '2018/05/24', '2018/05/25', 2262, '5872306631658736', 'OSH6282', 18, 400138),
('2018/10/05', '2018/10/20', '2018/10/05', '2018/10/19', 3284, '1232043003612781', 'EXM4840', 16, 875461),
('2018/11/26', '2018/12/02', '2018/11/29', '2018/11/30', 901, '9740428006482150', 'RIG0081', 20, 584326),
('2018/03/16', '2018/03/29', '2018/03/17', '2018/03/18', 3654, '2955958877692224', 'KWE3657', 2, 863002),
('2018/10/28', '2018/11/12', '2018/11/11', '2018/11/11', 700, '8710466254266035', 'ZUF6442', 18, 121190),
('2017/10/26', '2017/11/18', '2017/11/17', '2017/11/17', 1818, '5872306631658736', 'LFD5129', 19, 740545),
('2017/11/29', '2017/12/26', '2017/12/18', '2017/12/21', 1692, '9389088959916839', 'KWE3657', 10, 584535),
('2018/06/20', '2018/07/12', '2018/07/02', '2018/07/04', 3433, '2366699909471691', 'TLH1957', 13, 740545),
('2018/06/01', '2018/06/06', '2018/06/03', '2018/06/03', 127, '8309827635854232', 'RDV7473', 5, 212224),
('2018/01/15', '2018/02/06', '2018/01/27', '2018/01/27', 2224, '5793158292290620', 'CRD7250', 13, 829230),
('2019/02/06', '2019/02/18', '2019/02/09', '2019/02/15', 1210, '4453533484380790', 'LIQ6615', 14, 640379),
('2017/10/30', '2017/11/14', '2017/11/04', '2017/11/10', 1670, '5446795673541156', 'BOD6456', 3, 425165),
('2017/10/19', '2017/11/17', '2017/10/22', '2017/10/23', 1222, '5624157384542363', 'BQW2696', 3, 987823),
('2019/01/01', '2019/01/24', '2019/01/13', '2019/01/23', 2914, '5058374835755802', 'YAX7488', 2, 212224),
('2018/02/26', '2018/03/24', '2018/03/15', '2018/03/21', 2344, '0164673598729180', 'BOD6456', 17, 425165),
('2019/02/28', '2019/03/30', '2019/03/29', '2019/03/29', 3242, '2028059561969208', 'QTJ7481', 4, 987823),
('2018/07/28', '2018/08/13', '2018/07/30', '2018/08/06', 1152, '1026274905047007', 'VBQ6295', 3, 135133),
('2018/08/29', '2018/09/23', '2018/08/29', '2018/08/30', 2976, '5446795673541156', 'WCU7435', 11, 660067),
('2017/09/16', '2017/09/20', '2017/09/19', '2017/09/19', 2489, '4703769075447985', 'QTJ7481', 19, 909038),
('2017/10/02', '2017/10/20', '2017/10/04', '2017/10/06', 2752, '4231827175694223', 'BOD6456', 6, 439794),
('2018/10/10', '2018/10/13', '2018/10/10', '2018/10/11', 3676, '9740428006482150', 'DTH4206', 17, 584535),
('2019/02/09', '2019/02/24', '2019/02/17', '2019/02/24', 1515, '6811550540411180', 'OSH6282', 8, 278159),
('2017/11/29', '2017/12/04', '2017/11/29', '2017/12/03', 870, '0148135643297101', 'LFD5129', 6, 121190),
('2018/09/10', '2018/10/01', '2018/09/25', '2018/09/29', 3723, '4153115332480122', 'EKB8886', 19, 639191),
('2018/08/23', '2018/08/26', '2018/08/23', '2018/08/24', 822, '9175006746796231', 'TLH1957', 21, 640379),
('2018/10/30', '2018/11/28', '2018/11/24', '2018/11/27', 947, '4153115332480122', 'ONZ9142', 9, 829230),
('2018/11/04', '2018/11/18', '2018/11/17', '2018/11/17', 514, '0503597548816198', 'ONZ9142', 5, 584326),
('2018/06/26', '2018/06/30', '2018/06/27', '2018/06/28', 1139, '3430444922937210', 'TYC5213', 12, 640379),
('2018/08/06', '2018/09/02', '2018/08/06', '2018/08/19', 1733, '3430444922937210', 'YAX7488', 15, 875461),
('2017/10/14', '2017/10/17', '2017/10/16', '2017/10/16', 1710, '5872306631658736', 'WKP5966', 17, 909038),
('2018/09/05', '2018/10/01', '2018/09/20', '2018/09/29', 809, '6489738101432859', 'WKP5966', 15, 419263),
('2019/03/04', '2019/03/07', '2019/03/04', '2019/03/05', 798, '8615432804922962', 'LVQ2864', 14, 952566),
('2018/01/23', '2018/02/10', '2018/01/27', '2018/02/05', 1505, '4352976952518447', 'RDV7473', 12, 135133),
('2017/10/08', '2017/11/04', '2017/10/11', '2017/10/13', 1551, '2955958877692224', 'EKB8886', 2, 36563),
('2019/03/05', '2019/03/14', '2019/03/13', '2019/03/14', 3270, '9342049881153960', 'AXV8242', 16, 291497),
('2018/11/16', '2018/11/19', '2018/11/16', '2018/11/16', 2130, '0148135643297101', 'TYC5213', 8, 282294),
('2019/02/03', '2019/02/19', '2019/02/11', '2019/02/15', 2938, '2366699909471691', 'OSH6282', 20, 88644),
('2017/11/04', '2017/11/08', '2017/11/05', '2017/11/07', 3868, '5337145720469545', 'LFD5129', 9, 987823),
('2017/10/20', '2017/11/10', '2017/10/29', '2017/11/04', 256, '5446795673541156', 'RIG0081', 10, 584326),
('2018/05/21', '2018/06/12', '2018/06/07', '2018/06/11', 1203, '2010258917784258', 'LIQ6615', 17, 487445),
('2018/10/31', '2018/11/13', '2018/11/07', '2018/11/12', 1058, '5058374835755802', 'YAX7488', 1, 135133),
('2018/09/16', '2018/10/14', '2018/09/25', '2018/10/13', 2599, '7435851972902675', 'BDZ2271', 3, 127179),
('2018/12/27', '2019/01/18', '2018/12/27', '2019/01/17', 271, '7951743178126082', 'QZC4039', 19, 278159),
('2018/05/06', '2018/06/05', '2018/05/24', '2018/05/28', 262, '6289918798438792', 'LIQ6615', 14, 258628),
('2018/11/08', '2018/11/28', '2018/11/10', '2018/11/19', 880, '9373783468925556', 'EKB8886', 1, 562955),
('2019/01/11', '2019/01/27', '2019/01/26', '2019/01/27', 2511, '0976294373169649', 'VXF0628', 11, 925221),
('2018/05/24', '2018/06/13', '2018/06/09', '2018/06/11', 2202, '7078385618969144', 'OSH6282', 1, 562955),
('2018/06/20', '2018/07/14', '2018/06/29', '2018/07/05', 114, '6844462255499223', 'LBP8889', 8, 584535),
('2017/11/06', '2017/11/27', '2017/11/10', '2017/11/22', 998, '6969455266167842', 'BQW2696', 3, 258324),
('2017/08/05', '2017/08/11', '2017/08/11', '2017/08/11', 603, '1896190087283979', 'EKB8886', 3, 291497),
('2018/07/26', '2018/08/04', '2018/08/02', '2018/08/03', 1647, '6969455266167842', 'MUQ1793', 21, 584535),
('2017/10/05', '2017/10/23', '2017/10/11', '2017/10/12', 967, '4122341653444856', 'TYC5213', 19, 875461),
('2017/07/04', '2017/07/23', '2017/07/20', '2017/07/22', 1147, '9737270542700318', 'ZUF6442', 18, 258324),
('2019/10/04', '2019/10/11', null, null, 1940, '4122341653444856', 'MUQ1793', 14, 818352),
('2019/06/29', '2019/07/26', null, null, 1876, '9175006746796231', 'EJG0751', 12, 121190),
('2019/09/18', '2019/10/15', null, null, 1432, '3104103882536871', 'HUF0630', 7, 562955),
('2019/07/31', '2019/08/06', null, null, 3316, '5622829262463692', 'ONZ9142', 7, 785969),
('2019/07/13', '2019/07/16', null, null, 2780, '1362860607509246', 'WCU7435', 10, 402904),
('2019/06/24', '2019/06/27', null, null, 3693, '0503597548816198', 'AXV8242', 1, 691266),
('2019/10/04', '2019/10/29', null, null, 798, '1541755373290146', 'BOD6456', 13, 987823),
('2019/08/24', '2019/09/07', null, null, 3737, '9897525037772614', 'DST8994', 10, 762318),
('2019/08/20', '2019/09/19', null, null, 1235, '9740428006482150', 'RDV7473', 16, 68292),
('2019/08/03', '2019/08/29', null, null, 2571, '6969455266167842', 'IGV8025', 18, 121190),
('2019/09/28', '2019/10/15', null, null, 2593, '3986535013791794', 'QZC4039', 18, 798061),
('2019/10/04', '2019/11/03', null, null, 3960, '5624157384542363', 'LBP8889', 3, 278159),
('2019/10/03', '2019/10/12', null, null, 2992, '8710466254266035', 'LIQ6615', 7, 584326),
('2019/07/29', '2019/08/24', null, null, 559, '7078385618969144', 'LFD5129', 17, 542089),
('2019/08/03', '2019/08/06', null, null, 2136, '4231827175694223', 'HIS9889', 10, 662752),
('2019/06/30', '2019/07/08', null, null, 1684, '4703769075447985', 'HKC2075', 18, 434291),
('2019/08/26', '2019/09/14', null, null, 2920, '2010258917784258', 'QZC4039', 3, 419263),
('2019/08/09', '2019/08/28', null, null, 3479, '2063865610594357', 'BQW2696', 15, 258324),
('2019/08/20', '2019/09/02', null, null, 2173, '7435851972902675', 'DTH4206', 18, 278159),
('2019/10/03', '2019/10/19', null, null, 1518, '4453533484380790', 'EKB8886', 7, 278159),
('2019/09/06', '2019/09/11', null, null, 719, '4193191085622323', 'RIG0081', 20, 835795),
('2019/10/12', '2019/10/15', null, null, 1919, '5580844910364588', 'IGV8025', 7, 875461),
('2019/08/15', '2019/09/01', null, null, 3305, '2955320338850453', 'ONZ9142', 10, 762318),
('2019/08/22', '2019/09/07', null, null, 3272, '3808797874774703', 'ZUF6442', 15, 258628),
('2019/08/07', '2019/08/10', null, null, 449, '3523675564901481', 'TYC5213', 18, 121190),
('2019/10/05', '2019/10/28', null, null, 1278, '6489738101432859', 'VBQ6295', 6, 640379),
('2019/10/08', '2019/10/17', null, null, 2687, '1026274905047007', 'LIQ6615', 6, 365251),
('2019/08/07', '2019/08/19', null, null, 2738, '3997000013664959', 'LVQ2864', 2, 259139),
('2019/09/16', '2019/10/09', null, null, 3112, '4453533484380790', 'HIS9889', 12, 402904),
('2019/08/16', '2019/09/11', null, null, 1062, '2955958877692224', 'EKB8886', 21, 640379),
('2019/07/05', '2019/07/12', null, null, 1133, '5446795673541156', 'RIG0081', 11, 335492),
('2019/09/23', '2019/09/26', null, null, 2504, '0682109773312211', 'UEI7297', 3, 434291),
('2019/06/29', '2019/07/15', null, null, 3839, '3018174180063807', 'DTH4206', 2, 542089),
('2019/09/11', '2019/09/20', null, null, 1632, '0439403837169317', 'ZUF6442', 9, 259139),
('2019/09/12', '2019/09/27', null, null, 1127, '6949940454047607', 'HIS9889', 1, 562955),
('2019/07/11', '2019/07/16', null, null, 647, '3997000013664959', 'VBQ6295', 8, 875461),
('2019/10/15', '2019/11/13', null, null, 2732, '3430444922937210', 'LIQ6615', 20, 36563),
('2019/07/15', '2019/08/01', null, null, 2560, '1756524900797452', 'IGV8025', 17, 909038),
('2019/08/26', '2019/09/10', null, null, 1948, '7951743178126082', 'QTJ7481', 17, 885916),
('2019/08/21', '2019/08/24', null, null, 1334, '1896190087283979', 'RIG0081', 2, 316836),
('2019/09/28', '2019/10/21', null, null, 2586, '4153115332480122', 'ONZ9142', 18, 835795),
('2019/08/01', '2019/08/22', null, null, 498, '8348887936500108', 'OSH6282', 1, 925221),
('2019/07/24', '2019/07/30', null, null, 1252, '5833108118259674', 'OSH6282', 3, 365251),
('2019/07/17', '2019/08/07', null, null, 2226, '4193191085622323', 'LIQ6615', 9, 487445),
('2019/09/29', '2019/10/08', null, null, 1501, '5058374835755802', 'UEI7297', 11, 925221),
('2019/07/03', '2019/07/12', null, null, 2124, '6594023489766241', 'RIG0081', 1, 36563),
('2019/07/26', '2019/08/24', null, null, 798, '3200340842759528', 'FAK3425', 2, 419263),
('2019/08/07', '2019/09/02', null, null, 889, '5622829262463692', 'FWR5055', 4, 662752),
('2019/07/26', '2019/08/04', null, null, 3930, '4996199849118039', 'ESA9229', 5, 691266),
('2019/07/08', '2019/07/17', null, null, 456, '4568319087605057', 'FWR5055', 6, 909038),
('2019/07/27', '2019/08/13', null, null, 515, '0482171308138454', 'LIQ6615', 12, 402904),
('2019/07/21', '2019/07/25', null, null, 3622, '7951743178126082', 'DTH4206', 1, 258324),
('2019/07/28', '2019/08/15', null, null, 3558, '1756524900797452', 'QRV9560', 10, 487445),
('2019/07/30', '2019/08/15', null, null, 1905, '4955649653473582', 'EXM4840', 5, 439794),
('2019/10/02', '2019/10/06', null, null, 2856, '6936089517182693', 'EKB8886', 14, 829230),
('2019/08/01', '2019/08/21', null, null, 1759, '3152489765354858', 'FWR5055', 20, 762318),
('2019/07/16', '2019/08/09', null, null, 2908, '5793158292290620', 'FWR5055', 15, 135133),
('2019/10/13', '2019/10/31', null, null, 1735, '5337145720469545', 'RDV7473', 4, 135133),
('2019/08/06', '2019/08/09', null, null, 2960, '6811550540411180', 'FWR5055', 12, 925221),
('2019/08/14', '2019/09/11', null, null, 3518, '5591202357451503', 'BOD6456', 19, 127179),
('2019/10/04', '2019/10/11', null, null, 1940, '4122341653444856', 'MUQ1793', 6, 818352),
('2019/06/29', '2019/07/26', null, null, 1876, '9175006746796231', 'EJG0751', 4, 121190),
('2019/09/18', '2019/10/15', null, null, 1432, '3104103882536871', 'HUF0630', 1, 562955),
('2019/07/31', '2019/08/06', null, null, 3316, '5622829262463692', 'ONZ9142', 11, 785969),
('2019/07/13', '2019/07/16', null, null, 2780, '1362860607509246', 'WCU7435', 8, 402904),
('2019/06/24', '2019/06/27', null, null, 3693, '0503597548816198', 'AXV8242', 14, 691266),
('2019/10/04', '2019/10/29', null, null, 798, '1541755373290146', 'BOD6456', 4, 987823),
('2019/08/24', '2019/09/07', null, null, 3737, '9897525037772614', 'DST8994', 2, 762318),
('2019/08/20', '2019/09/19', null, null, 1235, '9740428006482150', 'RDV7473', 5, 68292),
('2019/08/03', '2019/08/29', null, null, 2571, '6969455266167842', 'IGV8025', 2, 121190),
('2019/09/28', '2019/10/15', null, null, 2593, '3986535013791794', 'QZC4039', 10, 798061),
('2019/10/04', '2019/11/03', null, null, 3960, '5624157384542363', 'LBP8889', 16, 278159),
('2019/10/03', '2019/10/12', null, null, 2992, '8710466254266035', 'LIQ6615', 12, 584326),
('2019/07/29', '2019/08/24', null, null, 559, '7078385618969144', 'LFD5129', 16, 542089),
('2019/08/03', '2019/08/06', null, null, 2136, '4231827175694223', 'HIS9889', 10, 662752),
('2019/06/30', '2019/07/08', null, null, 1684, '4703769075447985', 'HKC2075', 18, 434291),
('2019/08/26', '2019/09/14', null, null, 2920, '2010258917784258', 'QZC4039', 10, 419263),
('2019/08/09', '2019/08/28', null, null, 3479, '2063865610594357', 'BQW2696', 21, 258324),
('2019/08/20', '2019/09/02', null, null, 2173, '7435851972902675', 'DTH4206', 13, 278159),
('2019/10/03', '2019/10/19', null, null, 1518, '4453533484380790', 'EKB8886', 3, 278159),
('2019/09/06', '2019/09/11', null, null, 719, '4193191085622323', 'RIG0081', 3, 835795),
('2019/10/12', '2019/10/15', null, null, 1919, '5580844910364588', 'IGV8025', 17, 875461),
('2019/08/15', '2019/09/01', null, null, 3305, '2955320338850453', 'ONZ9142', 1, 762318),
('2019/08/22', '2019/09/07', null, null, 3272, '3808797874774703', 'ZUF6442', 5, 258628),
('2019/08/07', '2019/08/10', null, null, 449, '3523675564901481', 'TYC5213', 9, 121190),
('2019/10/05', '2019/10/28', null, null, 1278, '6489738101432859', 'VBQ6295', 17, 640379),
('2019/10/08', '2019/10/17', null, null, 2687, '1026274905047007', 'LIQ6615', 20, 365251),
('2019/08/07', '2019/08/19', null, null, 2738, '3997000013664959', 'LVQ2864', 12, 259139),
('2019/09/16', '2019/10/09', null, null, 3112, '4453533484380790', 'HIS9889', 10, 402904),
('2019/08/16', '2019/09/11', null, null, 1062, '2955958877692224', 'EKB8886', 14, 640379),
('2019/07/05', '2019/07/12', null, null, 1133, '5446795673541156', 'RIG0081', 8, 335492),
('2019/09/23', '2019/09/26', null, null, 2504, '0682109773312211', 'UEI7297', 6, 434291),
('2019/06/29', '2019/07/15', null, null, 3839, '3018174180063807', 'DTH4206', 8, 542089),
('2019/09/11', '2019/09/20', null, null, 1632, '0439403837169317', 'ZUF6442', 16, 259139),
('2019/09/12', '2019/09/27', null, null, 1127, '6949940454047607', 'HIS9889', 1, 562955),
('2019/07/11', '2019/07/16', null, null, 647, '3997000013664959', 'VBQ6295', 3, 875461),
('2019/10/15', '2019/11/13', null, null, 2732, '3430444922937210', 'LIQ6615', 13, 36563),
('2019/07/15', '2019/08/01', null, null, 2560, '1756524900797452', 'IGV8025', 2, 909038),
('2019/08/26', '2019/09/10', null, null, 1948, '7951743178126082', 'QTJ7481', 15, 885916),
('2019/08/21', '2019/08/24', null, null, 1334, '1896190087283979', 'RIG0081', 4, 316836),
('2019/09/28', '2019/10/21', null, null, 2586, '4153115332480122', 'ONZ9142', 17, 835795),
('2019/08/01', '2019/08/22', null, null, 498, '8348887936500108', 'OSH6282', 5, 925221),
('2019/07/24', '2019/07/30', null, null, 1252, '5833108118259674', 'OSH6282', 3, 365251),
('2019/07/17', '2019/08/07', null, null, 2226, '4193191085622323', 'LIQ6615', 2, 487445),
('2019/09/29', '2019/10/08', null, null, 1501, '5058374835755802', 'UEI7297', 12, 925221),
('2019/07/03', '2019/07/12', null, null, 2124, '6594023489766241', 'RIG0081', 6, 36563),
('2019/07/26', '2019/08/24', null, null, 798, '3200340842759528', 'FAK3425', 13, 419263),
('2019/08/07', '2019/09/02', null, null, 889, '5622829262463692', 'FWR5055', 3, 662752),
('2019/07/26', '2019/08/04', null, null, 3930, '4996199849118039', 'ESA9229', 13, 691266),
('2019/07/08', '2019/07/17', null, null, 456, '4568319087605057', 'FWR5055', 3, 909038),
('2019/07/27', '2019/08/13', null, null, 515, '0482171308138454', 'LIQ6615', 21, 402904),
('2019/07/21', '2019/07/25', null, null, 3622, '7951743178126082', 'DTH4206', 10, 258324),
('2019/07/28', '2019/08/15', null, null, 3558, '1756524900797452', 'QRV9560', 16, 487445),
('2019/07/30', '2019/08/15', null, null, 1905, '4955649653473582', 'EXM4840', 18, 439794),
('2019/10/02', '2019/10/06', null, null, 2856, '6936089517182693', 'EKB8886', 10, 829230),
('2019/08/01', '2019/08/21', null, null, 1759, '3152489765354858', 'FWR5055', 2, 762318),
('2019/07/16', '2019/08/09', null, null, 2908, '5793158292290620', 'FWR5055', 13, 135133),
('2019/10/13', '2019/10/31', null, null, 1735, '5337145720469545', 'RDV7473', 1, 135133),
('2019/08/06', '2019/08/09', null, null, 2960, '6811550540411180', 'FWR5055', 12, 925221),
('2019/08/14', '2019/09/11', null, null, 3518, '5591202357451503', 'BOD6456', 20, 127179);

insert into incidente (fk_reserva_id, data, valor) values 
(193, '2017/08/06', 4670),
(124, '2018/02/04', 592),
(54, '2018/01/19', 1583),
(169, '2017/10/03', 135),
(130, '2017/07/01', 904),
(8, '2017/12/24', 1016),
(165, '2018/01/18', 2485),
(3, '2017/07/15', 1903),
(34, '2017/11/28', 4190),
(140, '2017/08/14', 1765),
(171, '2017/10/28', 2927),
(185, '2017/12/31', 4772),
(169, '2017/09/27', 4463),
(92, '2017/11/22', 2802),
(66, '2017/11/28', 612),
(121, '2017/09/14', 3439),
(155, '2018/01/21', 2974),
(75, '2017/06/18', 4152),
(169, '2017/06/27', 1308),
(135, '2018/01/24', 518),
(11, '2017/11/28', 4540),
(185, '2018/02/05', 3781),
(91, '2017/10/25', 1719);

/*

	Nome da disciplina: Banco de Dados I
	Turma: 2019.1
    
	Trabalho Prático 1

	Sessão 3
	Consultas ao banco de dados

*/

/*
Descrição: Busca todos os funcionários que também são clientes
Resultado: 

Nome	Sobrenome
Sibbie	McClymond
Cassie	McNeish
Mia	Laxton

Comando:
*/
SELECT nome, sobrenome  FROM Funcionario WHERE (CPF) IN (SELECT CPF FROM Cliente);

/*

-> Uma consulta que envolva pelo menos uma cláusula IN
-> Consultas que usem pelo menos três tabelas (1/10)

Descrição: Busca os clientes que fizeram uma reserva para o dia 2017/12/07
Resultado: 

CPF				Nome
162.835.688-45	Siusan Vaudre

Comando:
*/
SELECT CPF, Nome FROM Cliente
 	WHERE (SELECT numero FROM CartaoCredito WHERE numero in ( SELECT fk_CartaoCredito_Numero FROM Locacao_Reserva WHERE dataInicio='2017/12/07' ) AND fk_Cliente_CPF=CPF);

/*

-> Uma consulta que envolva pelo menos uma cláusula EXISTS

Descrição: Busca os cartões de crédito que nunca foram usados numa reserva
Resultado: 

Numero				Validade	fk_Cliente_CPF
0402042719480236	2021-08-31	276.610.118-24
0935221815928757	2020-06-27	516.179.951-13
1104382039013001	2022-10-25	712.055.970-34
4108041900608682	2021-11-12	541.421.625-79
5521400097401214	2021-04-08	575.521.610-37
9492362727936404	2023-05-23	163.331.347-06
		

Comando: 
*/
SELECT * FROM CartaoCredito
	WHERE  NOT EXISTS
 ( SELECT CartaoCredito.Numero FROM Locacao_Reserva WHERE numero=fk_CartaoCredito_numero);
 
 /*

-> Uma consulta que envolva pelo menos uma função de agregação, incluindo as cláusulas GROUP BY e HAVING
-> Consultas que usem pelo menos três tabelas (2/10)

Descrição: Busca os modelos de carro que estiveram mais de dois incidentes
Resultado: 

Modelo					numero_incidente
Range Rover Classic		5
Passat					5
Mirage					5
Meriva					4
		
Comando:
*/
SELECT modelo, count(i.ID) numero_incidente FROM Veiculo ,Incidente i,Locacao_Reserva r
    WHERE   ( r.ID=i.fk_Reserva_ID AND Placa=fk_veiculo_placa)
    GROUP BY modelo
    HAVING numero_incidente > 2;

 /*

-> Uma consulta de divisão
-> Consultas que usem pelo menos três tabelas (3/10)

Descrição: Busca o CPF e o nome de todos os clientes que já reservaram pelo menos um carro de cada um dos modelos Mirage, Passat e Blazer.
Resultado: 

CPF				Nome
061.376.881-44	Michaela Cisco
062.777.968-51	Francisca MacCaull
165.661.113-85	Witty Luby
227.096.607-44	Sherie Hatto
237.179.782-68	Glad Antunez
277.442.596-61	Dom Shafe
360.485.474-56	Lynnette Assaf
363.253.921-42	Laird Cheeney
369.186.788-27	Buckie Sexton
516.179.951-13	Vallie Oleszcuk
531.007.052-94	Welbie Brizland
556.153.810-80	Artemus Tumilty
617.754.443-96	Federica Caberas
677.261.522-10	Merwin Washtell
722.765.786-52	Thebault Poge
723.823.320-68	Dory Ragate
742.673.517-77	Raddie Dulieu
750.304.004-88	Bendix Magog
767.354.449-90	Zollie Ranstead
954.585.915-16	Romain Really
957.783.120-41	Irma Tingey
966.791.837-13	Stevana Castellet
		
Comando:
*/
SELECT DISTINCT CPF, nome FROM cliente WHERE NOT EXISTS (
	SELECT modelo FROM veiculo WHERE modelo IN ('Mirage', 'Passat', 'Blazer') AND modelo NOT IN (
		SELECT modelo FROM (
			SELECT * FROM (
				SELECT * FROM locacao_reserva as lr
					JOIN cartaocredito as cc ON lr.fk_CartaoCredito_Numero = cc.numero
			) as t1 JOIN veiculo as v ON t1.fk_Veiculo_Placa = v.Placa
		) as t2 WHERE t2.fk_Cliente_CPF = cliente.CPF
	)
);

 /*

-> Consultas que usem pelo menos três tabelas (4/10)

Descrição: Encontrar os modelos dos veículos reservados nos últimos três meses, a data da reserva e quem os reservou
Resultado: ( Obs.: Resultado pode variar dependendo da data que o comando é executado, pois ele usa CURDATE() )

Modelo				data da reserva		quem reservou
Passat				2019-03-05			Christabella Finicj
Passat				2019-03-10			Kalila Klimashevich
D150				2019-03-16			Cam Neeson
Meriva				2019-03-06			Valentine Presho
Meriva				2019-03-04			Merwin Washtell
Meriva				2019-03-06			Clement Sergean
Range Rover Classic	2019-02-28			Garrett Libreros
D150				2019-03-12			Audre Huws
Range Rover Classic	2019-03-04			Artemus Tumilty
		
Comando:
*/
SELECT v.modelo, l.dataInicio AS 'data da reserva', c.nome AS 'quem reservou'
	FROM veiculo v, cliente c, locacao_reserva l, cartaocredito ca
	WHERE v.Placa = l.fk_Veiculo_Placa
			AND ca.Numero = l.fk_CartaoCredito_Numero
			AND c.CPF = ca.fk_Cliente_CPF
			AND DATEDIFF(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), l.dataInicio) < 90
			AND DATEDIFF(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), l.dataInicio) > 0;
            
 /*

-> Consultas que usem pelo menos três tabelas (5/10)

Descrição: Busca todos os funcionários que são gerentes que foram responsáveis por alguma manutenção
Resultado: 

ID	CPF				Nome		Sobrenome	fk_Filial_ID
7	952.531.971-41	Leilah		Crichten	4
10	717.414.399-93	Johann		Poznanski	5
11	869.226.589-96	Casandra	Rolf		5
12	976.290.780-17	Myra		Loades		3
19	917.627.253-66	Sibbie		McClymond	2
21	413.805.264-25	Mia			Laxton		6
				
Comando:
*/
SELECT f.* FROM funcionario f WHERE EXISTS ( 
	SELECT * FROM  manutencao m, gerente g WHERE m.fk_gerente_IDG AND g.fk_Funcionario_ID = f.ID);
    
 /*

-> Consultas que usem pelo menos três tabelas (6/10)

Descrição: Encontrar a soma dos valores dos pagamentos das reservas daqueles que tem pagamento tipo 1
Resultado: 

total
199563
				
Comando:
*/
SELECT SUM(l.valor) as "total" FROM locacao_reserva l, pagamento p, cartaocredito ca
WHERE l.fk_CartaoCredito_Numero = ca.Numero AND ca.fk_Cliente_CPF = p.fk_Cliente_CPF AND p.Pagamento_TIPO = 1; 
   
 /*

-> Consultas que usem pelo menos três tabelas (7/10)

Descrição: Encontrar as placas e os modelos de veículos usados que tem registro na manutenção com kilometragem maior que 20000 e nome dos gerentes responsáveis pela manutenção
Resultado: 

Nome		placa	modelo
Leilah		ZUF6442	Passat
Johann		AXV8242	Passat
Casandra	HIS9889	Mirage
Myra		OSH6282	Mirage
Myra		ZUF6442	Passat
Myra		QTJ7481	Range Rover Classic
Myra		OSH6282	Mirage
Myra		QRV9560	Meriva
Myra		MUQ1793	Meriva
Sibbie		BQW2696	Integra
Sibbie		BDZ2271	Meriva
Sibbie		DST8994	D150
Sibbie		CRD7250	Meriva
Sibbie		RIG0081	Passat
Sibbie		LIQ6615	Mirage
Sibbie		HIS9889	Mirage
Mia			AXV8242	Passat
Mia			QRV9560	Meriva
Mia			WKP5966	Integra
Mia			QTJ7481	Range Rover Classic
Mia			HKC2075	Mirage
Mia			FAK3425	Range Rover Classic
Mia			LVQ2864	Meriva
				
Comando:
*/
select f.Nome, v.placa, v.modelo from funcionario f, veiculo v, gerente g, manutencao m
where f.ID = g.fk_Funcionario_ID and v.Placa = m.fk_Veiculo_Placa and g.IDG = m.fk_Gerente_IDG and v.kilometragem > 20000;
   
    
 /*

-> Consultas que usem pelo menos três tabelas (8/10)

Descrição: Busca o endereço e o nome e o sobrenome do gerente das filiais que contêm todos os modelos de carros.
Resultado: 

endereco				Nome		Sobrenome
86 Talmadge Terrace		Mia			Laxton
				
Comando:
*/
SELECT DISTINCT endereco, funcionario.Nome, funcionario.Sobrenome FROM Veiculo as v1 
JOIN filial ON fk_Filial_ID = id JOIN gerente ON IDG = id JOIN funcionario ON gerente.fk_Funcionario_ID = funcionario.ID 
WHERE NOT EXISTS (
	SELECT modelo FROM Veiculo WHERE modelo NOT IN (  
		SELECT modelo FROM Veiculo as v2 WHERE v2.fk_Filial_id = v1.fk_Filial_id
	)
) ;

 /*

-> Uma consulta que envolva pelo menos uma operação de conjunto (UNION, INTERSECT, MINUS)
-> Consultas que usem pelo menos três tabelas (9/10)

Descrição: Descobrir todos os CPFs cadastrados no sistema.
Resultado: 

CPF
130.133.676-15
436.705.137-01
061.376.881-44
264.822.047-58
413.654.032-10
734.497.094-21
745.156.491-93
767.354.449-90
805.462.760-01
446.836.849-32
882.192.714-48
966.791.837-13
101.169.556-21
281.505.763-16
439.926.952-83
532.238.389-00
554.066.740-55
647.776.121-17
006.426.753-34
133.111.108-13
551.753.653-02
742.673.517-77
917.627.253-66
722.765.786-52
955.674.466-67
193.730.252-26
441.093.495-58
677.261.522-10
341.457.395-88
456.838.660-70
541.421.625-79
787.833.224-53
162.835.688-45
402.097.132-05
437.730.798-93
492.550.597-38
531.007.052-94
119.890.665-76
556.153.810-80
690.698.534-49
779.201.171-12
062.777.968-51
442.763.048-82
531.571.851-68
227.096.607-44
340.253.322-86
526.717.236-39
954.585.915-16
957.783.120-41
063.317.120-43
166.165.606-14
533.842.589-85
633.420.255-81
750.304.004-88
031.815.041-85
165.661.113-85
277.442.596-61
318.944.059-81
413.805.264-25
839.385.633-33
276.610.118-24
289.191.196-40
629.635.572-68
771.952.976-79
005.981.956-22
163.331.347-06
237.179.782-68
369.186.788-27
461.456.100-93
575.521.610-37
617.754.443-96
712.861.332-39
959.307.874-14
008.253.290-46
116.861.478-03
279.134.410-94
587.481.941-11
868.545.070-28
982.141.117-21
144.107.113-27
516.179.951-13
649.852.880-92
712.055.970-34
444.862.886-52
723.823.320-68
360.485.474-56
363.253.921-42
008.471.886-82
037.717.176-16
062.005.074-59
100.832.858-55
171.607.643-78
196.802.226-03
267.295.736-26
315.824.728-28
333.191.721-28
520.628.282-12
586.829.385-59
666.133.511-65
717.414.399-93
849.793.530-80
869.226.589-96
952.531.971-41
976.290.780-17
998.293.163-73
281.543.528-14
731.947.628-75
841.706.236-40
340.551.313-11
377.901.405-79
403.353.893-26
830.798.096-16
040.401.785-26
237.925.897-45
798.872.503-00
364.623.609-18
715.811.352-84
065.412.071-38
240.602.349-59
828.011.582-21
426.047.961-54
452.964.381-18
149.529.450-82
573.264.000-99
877.769.408-37
594.599.469-38
242.387.948-12
619.040.405-51
927.619.291-60
297.270.042-05
505.107.783-49
749.506.194-82
216.722.576-08
525.851.862-52
235.981.254-58
811.904.260-87
094.653.417-41
627.471.399-68
055.603.392-52
101.049.226-38
484.246.958-19
083.735.639-09
736.484.920-20
744.707.126-82
857.018.716-07
701.046.551-76
878.222.125-90
254.338.273-23
820.150.524-47
830.243.415-13
866.499.815-93
901.939.045-13
006.971.339-90
674.175.273-28
596.476.469-13
663.558.376-63
181.695.427-82
338.910.210-56
209.910.815-51
762.283.316-24
156.543.017-64
082.905.302-44
368.016.628-06
994.995.422-57
017.480.515-40
769.653.270-33
566.330.674-40
764.307.266-07
975.498.371-51
770.327.220-20
888.137.042-67
958.604.534-11
193.480.716-83
211.346.608-27
651.008.495-48
073.667.551-00
437.188.139-91
135.383.642-62
976.005.794-92
065.839.776-09
538.952.883-18
183.482.449-56
302.873.437-30
350.333.130-99
428.593.716-39
513.789.749-25
631.983.820-26
873.105.687-50
319.663.087-38
798.274.308-40
425.259.256-63
526.136.883-82
187.413.580-10
776.797.808-27
419.698.721-71
220.768.346-97
606.121.069-16
474.231.051-64
102.574.757-79
108.737.077-33
708.640.413-72
050.028.713-94
425.718.968-99
771.357.866-12
068.599.459-73
180.309.884-22
310.261.012-88
332.828.461-10
731.046.873-82
000.755.590-92
868.491.609-97
206.058.150-01
539.185.835-06
593.307.383-56
976.205.328-25
007.489.656-87
398.785.073-56
421.644.830-95
750.234.593-35
913.016.459-65
052.375.125-48
127.446.477-69
446.289.596-36
535.643.965-80
677.599.161-18

Comando:
*/
SELECT CPF FROM Cliente UNION SELECT CPF FROM Funcionario UNION SELECT CPF FROM Motorista;

    
 /*

-> Consultas que usem pelo menos três tabelas (10/10)

Descrição: O nome dos clientes que contém locações nas quais o veículo foi retirado e devolvido no mesmo dia.
Resultado: 

Nome
Francisca MacCaull
Coralie Ricardo
Siusan Vaudre
Witty Luby
Riccardo Balderson
Glad Antunez
Sisely Helder
Dom Shafe
Garrett Libreros
Kalila Klimashevich
Christabella Finicj
Artemus Tumilty
Maurene Urwin
Merwin Washtell
Thebault Poge
Dory Ragate
Basilio Lakenden
Bendix Magog
Zollie Ranstead
Ruby Tidey
Jo Dron
Katheryn MacQuaker
				
Comando:
*/
SELECT DISTINCT cliente.nome as "Nome do cliente" FROM locacao_reserva as l 
JOIN cartaocredito ON Numero=fk_CartaoCredito_Numero JOIN cliente ON CPF=fk_Cliente_CPF
WHERE DATEDIFF(l.datadevolucao, l.dataretirada) = 0;

/*

	Nome da disciplina: Banco de Dados I
	Turma: 2019.1
    
	Trabalho Prático 1

	Sessão 4
	Papéis de usuários e usuários da base da dados

*/

/*USER VISITANTE
o visitante na loja tem a possibilidade de ver os veiculos disponiveis para escolher um.Ele pode ver em qual loja fica cada veiculo.
*/

drop user if exists visitante@localhost;
create user visitante@localhost;

drop view if exists CarrosDisponiveis;
create view CarrosDisponiveis as
select modelo,ano,endereco as endereco_loja
from Veiculo inner join Filial on fk_Filial_ID=ID left join Locacao_Reserva  on Placa=fk_Veiculo_Placa
where dataFim< CURDATE() or dataFim is NULL;

grant select on CarrosDisponiveis to visitante@localhost;
 
/*USER CLIENTE
O Cliente pode ver tudo que tem a ver com ele. 
*/

drop user if exists Dorine@localhost;
create user Dorine@localhost IDENTIFIED BY '2973859';

drop view if exists Dorine_dados;
create view Dorine_dados as

select  dataRetirada,dataDevolucao,dataInicio,dataFim,r.valor,fk_veiculo_placa as veiculo_placa,modelo,ano,i.data as data_incidente,i.valor as valor_incidente
from Cliente  inner join CartaoCredito  on CPF=fk_Cliente_CPF inner join Locacao_Reserva r on fk_CartaoCredito_Numero=Numero inner join Veiculo on fk_veiculo_placa=Placa left join Incidente i on fk_Reserva_ID=r.ID
where CPF='097.012.447-04';

grant select on Dorine_dados to  Dorine@localhost ;

/* USER/ROLE FUNCIONARIO
Funcionário da filial 1, pode inserir novos clientes,novas reservações mas pode ver só o que concerna sua filial. Não pode ver as manutenções ou os incidentes
*/

drop user if exists Brenden_Harford@localhost;
drop user if exists Gherardo_Bett@localhost;
create user Brenden_Harford@localhost identified by '4692970';
create user Gherardo_Bett@localhost identified by '2694809';

drop view if exists Veiculo_Filial_1;
create view Veiculo_Filial_1 as
select Placa,modelo,ano,kilometragem
from Veiculo 
where fk_Filial_ID='1';

drop view if exists Reserva_Filial_1;
create view Reserva_Filial_1 as
select r.*
from Locacao_Reserva r inner join Funcionario f on fk_Funcionario_ID=f.ID
where fk_Filial_ID='1';

drop role if exists funcionario_1;
create role funcionario_1;
grant select,insert,update on Cliente to funcionario_1;
grant select on Veiculo_Filial_1 to funcionario_1;
grant select,insert,update on Reserva_Filial_1 to funcionario_1;

grant  funcionario_1 to Brenden_Harford@localhost;
grant  funcionario_1 to Gherardo_Bett@localhost;

/*  USER/ROLE GERENTE
Gerente da filial 1, pode fazer tudo o que pode fazer um funcionário da filial 1 mas tem acesso às manutenções e os incidentes
*/

drop view if exists Reserva_Incidentes_1;
create view Reserva_Incidentes_1 as
select r.*,i.ID as ID_incidente,i.data as data_incidente,i.valor as valor_incidente
from Reserva_Filial_1 r inner join Incidente i on fk_Reserva_ID=r.ID;

drop view if exists Manutencao_1;
create view Manutencao_1 as
select c.*,m.dataInicio as data_inicio_manutencao, m.dataFim as data_fim_manutencao,m.descricao,m.fk_Gerente_IDG as gerente_responsavel
from  Veiculo_Filial_1 c inner join Manutencao m on fk_Veiculo_Placa=Placa;

drop role if exists gerente_1;
create role gerente_1;
grant funcionario_1 to gerente_1;
grant select, insert,update on Reserva_Incidentes_1 to gerente_1;
grant select, insert,update on Manutencao_1 to gerente_1;

/*

	Nome da disciplina: Banco de Dados I
	Turma: 2019.1
    
	Trabalho Prático 1

	Sessão 5
	PL/SQL (criações, inserções, atualizações e mostra de dados)

*/

/*
    Este procedimento cria e preenche a tabela de modelos de carros com suas respectivas marcas.
    Atende o seguinte requisito:
    - Pelo menos um procedimento que envolva a criação e o povoamento de uma (ou mais) nova(s) tabela(s);
*/
DROP PROCEDURE IF EXISTS create_marcas_e_modelos;
DELIMITER //

CREATE PROCEDURE create_marcas_e_modelos()
BEGIN

    DROP TABLE IF EXISTS marcas_veiculos;
    CREATE TABLE marcas_veiculos (

        nome varchar(255) PRIMARY KEY

    );

    INSERT INTO marcas_veiculos VALUES ('Volkswagen');
    INSERT INTO marcas_veiculos VALUES ('Peugeot');
    INSERT INTO marcas_veiculos VALUES ('FIAT');
    INSERT INTO marcas_veiculos VALUES ('BMW');

    DROP TABLE IF EXISTS modelos_veiculos;
    CREATE TABLE modelos_veiculos (

        id int AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(255),
        fk_nome_marca VARCHAR(255),
        FOREIGN KEY (fk_nome_marca) REFERENCES marcas_veiculos (nome)

    );

    INSERT INTO modelos_veiculos VALUES (1, 'C-Class', 'Volkswagen');
    INSERT INTO modelos_veiculos VALUES (2, 'D150', 'Peugeot');
    INSERT INTO modelos_veiculos VALUES (3, 'Mirage', 'FIAT');
    INSERT INTO modelos_veiculos VALUES (4, 'Passat', 'BMW');
    INSERT INTO modelos_veiculos VALUES (5, 'Range Rover Classic', 'Volkswagen');
    INSERT INTO modelos_veiculos VALUES (6, 'Laser', 'Peugeot');
    INSERT INTO modelos_veiculos VALUES (7, 'Xterra', 'FIAT');
    INSERT INTO modelos_veiculos VALUES (8, 'Integra', 'Peugeot');
    INSERT INTO modelos_veiculos VALUES (9, 'Econoline E150', 'FIAT');
    INSERT INTO modelos_veiculos VALUES (10, 'Blazer', 'FIAT');

END //

DELIMITER ;


/*
    Este procedimento pega o histórico de veículos que um determinado cliente já reservou.
    Atende o seguinte requisito:
    (1/3) - Pelo menos 3 procedimentos que envolvam a execução de transações derivadas de requisitos elicitados no minimundo.
*/
DROP PROCEDURE IF EXISTS get_historico_veiculos_cliente;
DELIMITER //

CREATE PROCEDURE get_historico_veiculos_cliente(IN cpf VARCHAR(14))
BEGIN

    SELECT v.modelo, v.Placa, c.Nome, c.CPF
    FROM veiculo v, cliente c, locacao_reserva l, cartaocredito cc
    WHERE v.Placa = l.fk_Veiculo_Placa
        AND cc.Numero = l.fk_CartaoCredito_Numero
        AND c.CPF = cc.fk_Cliente_CPF
        AND c.CPF = cpf;

END //

DELIMITER ;


/*
    Este procedimento pega o histórico de veículos que um determinado cliente já reservou.
    Atende o seguinte requisito:
    (2/3) - Pelo menos 3 procedimentos que envolvam a execução de transações derivadas de requisitos elicitados no minimundo.
*/
DROP PROCEDURE IF EXISTS get_veiculos_filial;
DELIMITER //

CREATE PROCEDURE get_veiculos_filial(IN filial_id INT)
BEGIN

    SELECT v.modelo, v.Placa, f.ID, f.Endereco
    FROM veiculo v, filial f
    WHERE v.fk_Filial_ID = f.ID
        AND f.ID = filial_id;

END //

DELIMITER ;


/*
    Este procedimento retorna quanto um cliente deve à empresa por incidentes com os carros
    Atende o seguinte requisito:
    (3/3) - Pelo menos 3 procedimentos que envolvam a execução de transações derivadas de requisitos elicitados no minimundo.
*/
DROP PROCEDURE IF EXISTS get_valor_incidentes_cliente;
DELIMITER //

CREATE PROCEDURE get_valor_incidentes_cliente(IN cpf VARCHAR(14))
BEGIN

    SELECT CONCAT("R$ ", FORMAT(SUM(i.valor), 2 ,'de_DE')) AS "dívida", c.Nome, c.CPF
    FROM incidente i, cliente c, locacao_reserva r, cartaocredito cc
    WHERE i.fk_Reserva_ID = r.ID
        AND cc.Numero = r.fk_CartaoCredito_Numero
        AND c.CPF = cc.fk_Cliente_CPF
        AND c.CPF = cpf;

END //

DELIMITER ;


/*
    Este procedimento atualiza a kilometragem de um veículo
    Atende o seguinte requisito:
    - Pelo menos um procedimento que envolva a remoção ou a atualização de tuplas em uma tabela já existente;
*/
DROP PROCEDURE IF EXISTS update_kilometragem_carro;
DELIMITER //

CREATE PROCEDURE update_kilometragem_carro(IN placa VARCHAR(255), IN km INT)
BEGIN

    UPDATE veiculo
    SET kilometragem = km
    WHERE Placa = placa;

END //

DELIMITER ;
