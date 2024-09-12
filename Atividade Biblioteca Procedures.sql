-- Autor: Augusto Corrêa  Disciplina: Banco de Dados Avançado
CREATE DATABASE Biblioteca;

USE Biblioteca;

-- Criação das tabelas
CREATE TABLE Usuario (
    Id_Usuario INT PRIMARY KEY NOT NULL,
    Nome VARCHAR(45) NOT NULL,
    Sobrenome VARCHAR(45) NOT NULL,
    Data_Nascimento DATE NOT NULL,
    CPF INT NOT NULL
);

CREATE TABLE Livro (
    Id_Livro INT PRIMARY KEY NOT NULL,
    Nome VARCHAR(45) NOT NULL,
    Autor VARCHAR(45) NOT NULL
);

CREATE TABLE Emprestimo (
    Id_Emprestimo INT PRIMARY KEY,
    Id_Livro INT,
    Id_Usuario INT,
    FOREIGN KEY (Id_Livro) REFERENCES Livro(Id_Livro),
    FOREIGN KEY (Id_Usuario) REFERENCES Usuario(Id_Usuario)
);

CREATE TABLE Multa (
    Id_Multa INT AUTO_INCREMENT PRIMARY KEY,
    Id_Usuario INT,
    Valor_Multa DECIMAL(10,2),
    Data_Multa DATE,
    FOREIGN KEY (Id_Usuario) REFERENCES Usuario(Id_Usuario)
);

CREATE TABLE Devolucao (
    Id_Devolucao INT AUTO_INCREMENT PRIMARY KEY,
    Id_Livro INT,
    Id_Usuario INT,
    Data_Devolucao DATE,
    Data_Devolucao_Esperada DATE,
    FOREIGN KEY (Id_Livro) REFERENCES Livro(Id_Livro),
    FOREIGN KEY (Id_Usuario) REFERENCES Usuario(Id_Usuario)
);

CREATE TABLE Livro_Atualizado (
    Id_Livro_Atualizado INT PRIMARY KEY,
    Id_Livro INT,
    Titulo VARCHAR(100),
    Autor VARCHAR(300),
    Data_Atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Livro_Excluido (
    Id_Livro_Excluido INT PRIMARY KEY,
    Id_Livro INT,
    Titulo VARCHAR(110),
    Autor VARCHAR(110),
    Data_Exclusao DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Mensagem (
    Id_Mensagem INT PRIMARY KEY,
    Assunto VARCHAR(45),
    Corpo VARCHAR(45)
);

-- Inserção de exemplo
INSERT INTO Usuario VALUES (1, 'Manuel', 'Gomes', '1960-04-22', 284472983);

INSERT INTO Livro VALUES (1, 'Caneta Azul', 'Manuel Homi');

INSERT INTO Livro_Excluido VALUES (1, 1, 'Livro', 'Pedro', '2024-09-12');

INSERT INTO Multa VALUES (1, 1, 10.00, '2024-09-13');

INSERT INTO Devolucao VALUES (1, 1, 1, '2024-09-20', '2024-10-20');

INSERT INTO Livro_Atualizado VALUES (2, 1, 'Harry Potter', 'Arthur', '2024-09-12');

-- Consultas de exemplo
SELECT * FROM Usuario;

SELECT * FROM Livro;

SELECT * FROM Livro_Excluido;

SELECT * FROM Multa;

SELECT * FROM Livro_Atualizado;

SELECT * FROM Devolucao;

-- Trigger para aplicar multa quando há um atraso na devolução
DELIMITER //

CREATE TRIGGER Trigger_Multa
AFTER INSERT ON Devolucao
FOR EACH ROW
BEGIN
    DECLARE Atraso INT;
    DECLARE Valor_Multa DECIMAL(10,2);

    IF NEW.Data_Devolucao_Esperada IS NOT NULL AND NEW.Data_Devolucao IS NOT NULL THEN
        SET Atraso = DATEDIFF(NEW.Data_Devolucao, NEW.Data_Devolucao_Esperada);

        IF Atraso > 0 THEN
            SET Valor_Multa = Atraso * 2.00;
            INSERT INTO Multa (Id_Usuario, Valor_Multa, Data_Multa)
            VALUES (NEW.Id_Usuario, Valor_Multa, NOW());
        END IF;
    END IF;
END //

DELIMITER ;

-- Trigger para verificar atraso e notificar o bibliotecário
DELIMITER //

CREATE TRIGGER Trigger_Verificar_Atraso
BEFORE INSERT ON Devolucao
FOR EACH ROW
BEGIN
    DECLARE Atraso INT;

    SET Atraso = DATEDIFF(NEW.Data_Devolucao_Esperada, NEW.Data_Devolucao);

    IF Atraso > 0 THEN
        INSERT INTO Mensagem (Assunto, Corpo)
        VALUES (
            'Alerta de Atraso',
            CONCAT('O livro com Id ', NEW.Id_Livro, ' não foi devolvido na data esperada.')
        );
    END IF;
END //

DELIMITER ;

-- Trigger para atualizar o status do livro para "emprestado" após o empréstimo
DELIMITER //

CREATE TRIGGER Trigger_Atualizar_Status_Livro
AFTER INSERT ON Emprestimo
FOR EACH ROW
BEGIN
    UPDATE Livro
    SET Status_Livro = 'Emprestado'
    WHERE Id_Livro = NEW.Id_Livro;
END //

DELIMITER ;

-- Trigger para atualizar o número total de exemplares após inserção de um novo livro
DELIMITER //

CREATE TRIGGER Trigger_Atualizar_Total_Exemplares
AFTER INSERT ON Livro
FOR EACH ROW
BEGIN
    UPDATE Livro
    SET Total_Exemplares = Total_Exemplares + 1
    WHERE Id_Livro = NEW.Id_Livro;
END //

DELIMITER ;

-- Trigger para registrar atualizações em livros
DELIMITER //

CREATE TRIGGER Trigger_Registrar_Atualizacao_Livro
AFTER UPDATE ON Livro
FOR EACH ROW
BEGIN
    INSERT INTO Livro_Atualizado (Id_Livro, Titulo, Autor, Data_Atualizacao)
    VALUES (OLD.Id_Livro, OLD.Nome, OLD.Autor, NOW());
END //

DELIMITER ;

-- Trigger para registrar exclusões de livros
DELIMITER //

CREATE TRIGGER Trigger_Registrar_Exclusao_Livro
AFTER DELETE ON Livro
FOR EACH ROW
BEGIN
    INSERT INTO Livro_Excluido (Id_Livro, Titulo, Autor, Data_Exclusao)
    VALUES (OLD.Id_Livro, OLD.Nome, OLD.Autor, NOW());
END //

DELIMITER ;

-- Procedure para calcular a média de multas entre dois anos
DELIMITER //

CREATE PROCEDURE Calcular_Media_Multas_Periodo(IN Ano_Inicial INT, IN Ano_Final INT)
BEGIN
    SELECT AVG(Valor_Multa) AS Media_Valor_Multas
    FROM Multa
    WHERE YEAR(Data_Multa) BETWEEN Ano_Inicial AND Ano_Final;
END //

DELIMITER ;

-- Chamando a procedure
CALL Calcular_Media_Multas_Periodo(2022, 2024);
