-- Autor: Augusto Corrêa  Disciplina: Banco de Dados Avançado
CREATE DATABASE Halloween;

USE Halloween;

-- Criação da tabela
CREATE TABLE Usuario (
    Id_Usuario INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Idade INT NOT NULL
);

-- Inserção de exemplo
INSERT INTO Usuario (Nome, Email, Idade)
VALUES ('Teste da Silva Junior', 'teste@uol.com', 16);

-- Consulta
SELECT * FROM Usuario;


DELIMITER $$

-- Criação da procedure
CREATE PROCEDURE InsereUsuariosAleatorios()
BEGIN
    DECLARE i INT DEFAULT 0;

    -- Loop de 10.000 
    WHILE i < 10000 DO
        
        SET @Nome := CONCAT('Usuario', i);
        SET @Email := CONCAT('usuario', i, '@exemplo.com');
        SET @Idade := FLOOR(RAND() * 80) + 18;  -- Gera uma idade entre 18 e 97 anos

        -- Inserir o novo registro na tabela
        INSERT INTO Usuario (Nome, Email, Idade)
        VALUES (@Nome, @Email, @Idade);

        -- Incrementa o contador
        SET i = i + 1;
    END WHILE;
END $$


DELIMITER ;

-- Chamar a procedure
CALL InsereUsuariosAleatorios();
