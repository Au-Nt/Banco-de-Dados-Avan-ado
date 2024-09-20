-- Autor: Augusto Corrêa RGM: 11221101575
Create Database clinica_vet;
use clinica_vet;

-- Criação das tabelas
Create Table Paciente (
id_paciente INTEGER PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100),
especie VARCHAR(50),
 idade INTEGER
 );
 
Create table Veterinarios (
id_veterinario INTEGER PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100),
especialidade VARCHAR(50)
);

Create table Consultas (
id_consulta INTEGER PRIMARY KEY AUTO_INCREMENT,
id_paciente INTEGER,
id_veterinario INTEGER,
data_consulta DATE,
custo DECIMAL(10, 2),
FOREIGN KEY (id_paciente) References Paciente (id_paciente),
FOREIGN KEY (id_veterinario) References Veterinarios (id_veterinario)
);

-- Criação das Stored Procedures
DELIMITER $$

	CREATE PROCEDURE agendar_consulta (
		id_paciente INTEGER,
		id_veterinario INTEGER,
		data_consulta DATE,
		custo DECIMAL(10, 2)
	 )
	BEGIN
		INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo)
			VALUES (id_paciente, id_veterinario, data_consulta, custo);
	END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE atualizar_paciente (
	IN id_paciente INTEGER,
    novo_nome VARCHAR (100),
    nova_especie VARCHAR (50),
    nova_idade INTEGER
    )
	BEGIN
		UPDATE Paciente SET nome = novo_nome, idade = nova_idade
        WHERE id_paciente=id_paciente;
    END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE remover_consulta (IN id_consulta INTEGER)
	BEGIN
		DELETE FROM Consultas
		WHERE id_consulta = id_consulta;
    END $$

DELIMITER ;

-- Criação das Functions
DELIMITER $$
	CREATE FUNCTION  total_gasto_paciente ( id_paciente INTEGER)
    RETURNS INTEGER
    BEGIN
		  DECLARE valor_total_consultas INTEGER;
          SELECT SUM(custo) INTO valor_total_consultas
          FROM Consultas 
          WHERE id_paciente = id_paciente;
          RETURN valor_total_consultas;
	END $$
DELIMITER ;

-- Criação das Triggers
DELIMITER $$
	CREATE TRIGGER verificar_idade_paciente
    BEFORE INSERT ON Paciente
    FOR EACH ROW
    BEGIN
		IF NEW.idade <=0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Dados incorretos';
		END IF;
	END $$
DELIMITER ;

-- Criação da tabela de log
CREATE TABLE Log_Consultas (
id_log INTEGER PRIMARY KEY AUTO_INCREMENT,
id_consulta INTEGER,
custo_antigo DECIMAL (10,2),
custo_novo  DECIMAL (10,2)
);

-- Trigger de Log
DELIMITER $$
	CREATE TRIGGER  atualizar_custo_consulta
    AFTER UPDATE ON Consultas
    FOR EACH ROW
     BEGIN
     IF OLD.custo <> New.custo THEN
		INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
	 END $$
DELIMITER ;

-- Teste de Funcionamento
INSERT INTO Paciente (nome, especie, idade) VALUES ('Jake', 'Cachorro', 4);
SELECT * FROM Paciente;

INSERT INTO Veterinarios (nome, especialidade) VALUES ('Dr. Datena', 'Cadeira');
SELECT * FROM Veterinarios;

INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo) VALUES (1, 1, '2024-10-01', 400.00);
SELECT * FROM Consultas;

CALL agendar_consulta(1, 1, '2024-09-04', 1000.00);
SELECT * FROM Consultas;

CALL atualizar_paciente(1, 'TRex', 'Dinossauro', 6000);
SELECT * FROM Paciente;

CALL remover_consulta(1);
SELECT * FROM Consultas;
-- Teste de trigger para dados incorretos
INSERT INTO Paciente (nome, especie, idade) VALUES ('bINGUS', 'Gato', -1);
-- Teste de trigger para dados corrigidos
INSERT INTO Paciente (nome, especie, idade) VALUES ('bINGUS', 'Gato', 5);

-- Teste trigger de atualização
UPDATE Consultas
SET custo = 250.00
WHERE id_consulta = 2;

SELECT * FROM Log_Consultas;

-- Parte 2 M1
-- Criação de 3 tabelas
CREATE TABLE Remedios (
   id_remedio INTEGER PRIMARY KEY AUTO_INCREMENT,
   nome VARCHAR(50),
   descricao VARCHAR(200),
   tipo VARCHAR (100),
   preco DECIMAL(10, 2)
);

CREATE TABLE Receitas (
   id_receita INTEGER PRIMARY KEY AUTO_INCREMENT,
   id_consulta INTEGER,
   id_remedio INTEGER,
   quantidade INTEGER,
   pescricao VARCHAR (500),
   FOREIGN KEY (id_consulta) References Consultas(id_consulta),
   FOREIGN KEY (id_remedio) References Remedios(id_remedio)
);

CREATE TABLE Vacinas (
   id_vacina INTEGER PRIMARY KEY AUTO_INCREMENT,
   id_paciente INTEGER,
   id_veterinario INTEGER,
   nome_vacina VARCHAR(100),
   data_aplicacao DATE,
   FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente),
   FOREIGN KEY (id_veterinario) REFERENCES Veterinarios(id_veterinario)
);

-- Criação de 5 triggers
DELIMITER $$
	CREATE TRIGGER verificar_preco_remedios
	BEFORE INSERT ON Remedios
	FOR EACH ROW
	BEGIN
		   IF NEW.preco <= 0 THEN
			  SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'Preço do remédio inválido';
		   END IF;
	END $$
DELIMITER ;
-- Teste rápido
INSERT INTO remedios (nome, descricao, tipo, preco) VALUES ('Dramim', 'remédio aí','comprimido', 0);
INSERT INTO remedios (nome, descricao, tipo, preco) VALUES ('Dramim', 'remédio aí','comprimido', -1);

DELIMITER $$
	CREATE TRIGGER verificar_idade_paciente
	BEFORE INSERT ON Paciente
	FOR EACH ROW
	BEGIN
		   IF NEW.idade < 0 THEN
			  SIGNAL SQLSTATE '45000'
			  SET MESSAGE_TEXT = 'Idade do paciente não pode ser negativa';
		   END IF;
	END $$
DELIMITER ;

DELIMITER $$
	CREATE TRIGGER verificar_quantidade_receita
	BEFORE INSERT ON Receitas
	FOR EACH ROW
	BEGIN
		IF NEW.quantidade <= 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'A quantidade do remédio não pode ser nula ou negativa';
		END IF;
	END $$
DELIMITER ;

DELIMITER $$
	CREATE TRIGGER verificar_custo_consulta
	BEFORE INSERT ON Consultas
	FOR EACH ROW
	BEGIN
		IF NEW.custo < 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'O custo da consulta inválida';
		END IF;
	END $$
DELIMITER ;

DELIMITER $$
	CREATE TRIGGER verificar_nome_vacina
	BEFORE UPDATE ON Vacinas
	FOR EACH ROW
	BEGIN
		IF NEW.nome_vacina IS NULL OR NEW.nome_vacina = '' THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'O nome da vacina inválido';
		END IF;
	END $$
DELIMITER ;

-- Criação de 5 procedures
DELIMITER $$
	CREATE PROCEDURE listar_consultas_paciente (IN id_paciente INTEGER)
		BEGIN
		   SELECT * FROM Consultas WHERE id_paciente = id_paciente;
		END $$
DELIMITER ;

CALL listar_consultas_paciente(1);

DELIMITER $$
CREATE PROCEDURE atualizar_preco_remedio (
   IN id_remedio INTEGER,
	novo_preco DECIMAL(10, 2)
)
	BEGIN
	   UPDATE Remedios SET preco = novo_preco
       WHERE id_remedio = id_remedio;
	END $$
DELIMITER ;

CALL atualizar_preco_remedio(1, 45.00);

DELIMITER $$
CREATE PROCEDURE buscar_receita_por_consulta (
   IN id_consulta INTEGER
)
	BEGIN
	   SELECT * FROM Receitas
       WHERE id_consulta = id_consulta;
	END $$
DELIMITER ;

CALL buscar_receita_por_consulta (1);

DELIMITER $$
	CREATE PROCEDURE buscar_remedio_por_preco (IN preco_min DECIMAL(10, 2))
		BEGIN
		   SELECT * FROM Remedios
           WHERE preco >= preco_min;
		END $$
DELIMITER ;

CALL buscar_remedio_por_preco(40.00);

DELIMITER $$
CREATE PROCEDURE atualizar_data_vacina (
   IN id_vacina INTEGER,
   nova_data DATE
)
	BEGIN
	   UPDATE Vacinas SET data_aplicacao = nova_data
	   WHERE id_vacina = id_vacina;
	END $$
DELIMITER ;

CALL atualizar_data_vacina(1, '2024-09-04');









