-- Autor: Augusto Corrêa  Disciplina: Banco de Dados Avançado
CREATE DATABASE Teatro;

USE Teatro;

-- Criação das tabelas
CREATE TABLE Pecas_Teatro (
    Id_Peca INT AUTO_INCREMENT PRIMARY KEY,
    Nome_Peca VARCHAR(45) NOT NULL,
    Descricao VARCHAR(45) NOT NULL
);


CREATE TABLE Exibicao (
    Id_Exibicao INT AUTO_INCREMENT PRIMARY KEY,
    Id_Peca INT NOT NULL,
    Duracao INT NOT NULL,
    Data_Hora DATETIME NOT NULL,
    FOREIGN KEY (Id_Peca) REFERENCES Pecas_Teatro(Id_Peca)
);

-- Testes de Inserçãe e Seleção
INSERT INTO Pecas_Teatro (Nome_Peca, Descricao)
VALUES ('Fantasma da Ópera', 'Fantasma Maluco');


SELECT * FROM Pecas_Teatro;


INSERT INTO Exibicao (Id_Peca, Duracao, Data_Hora)
VALUES (1, 120, '2024-09-15 20:00:00');


SELECT * FROM Exibicao;


DELIMITER $$

-- Função para Calcular a Média de Duração das Exibições
CREATE FUNCTION Calcular_Media_Duracao(Id_Peca INT)
RETURNS FLOAT
BEGIN
    DECLARE Media_Duracao FLOAT;
    SELECT AVG(Duracao) INTO Media_Duracao
    FROM Exibicao
    WHERE Id_Peca = Id_Peca;
    RETURN Media_Duracao;
END $$

-- Função para Verificar Disponibilidade
CREATE FUNCTION Verificar_Disponibilidade(Data_Hora DATETIME)
RETURNS BOOLEAN
BEGIN
    DECLARE Disponibilidade INT;
    SELECT COUNT(*) INTO Disponibilidade
    FROM Exibicao
    WHERE Data_Hora = Data_Hora;
    
    IF Disponibilidade > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$

-- Procedure para agendar uma nova Peça
CREATE PROCEDURE Agendar_Peca (
    IN Nome_Peca VARCHAR(45),
    IN Descricao VARCHAR(45),
    IN Data_Hora DATETIME,
    IN Duracao INT
)
BEGIN
    DECLARE Id_Peca INT;
    DECLARE Media_Duracao FLOAT;

    -- Verificar Disponibilidade de Horário
    IF Verificar_Disponibilidade(Data_Hora) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Já existe uma exibição agendada para esta data e hora.';
    ELSE
        -- Inserir Nova Peça na Tabela Pecas_Teatro
        INSERT INTO Pecas_Teatro (Nome_Peca, Descricao)
        VALUES (Nome_Peca, Descricao);


        SET Id_Peca = LAST_INSERT_ID();

        -- Inserir Nova Exibição 
        INSERT INTO Exibicao (Id_Peca, Duracao, Data_Hora)
        VALUES (Id_Peca, Duracao, Data_Hora);

        -- Calcular a Média
        SET Media_Duracao = Calcular_Media_Duracao(Id_Peca);

        -- Exibir Informações 
        SELECT 
            Nome_Peca,
            Descricao,
            Data_Hora AS Data_Hora_Exibicao,
            Duracao,
            Media_Duracao AS Media_Duracao
        FROM Pecas_Teatro
        JOIN Exibicao ON Pecas_Teatro.Id_Peca = Exibicao.Id_Peca
        WHERE Pecas_Teatro.Id_Peca = Id_Peca;
    END IF;
END $$


DELIMITER ;

-- Testes
CALL Agendar_Peca('Romeu e Julieta', 'Uma tragédia romântica de William Shakespeare.', '2024-09-15 20:00:00', 130);
CALL Agendar_Peca('Teste', 'Amostradinho', '2024-09-15 22:00:00', 40);


SELECT Verificar_Disponibilidade('2024-09-15 20:00:00');

-- Agendar Mais Algumas Peças
CALL Agendar_Peca('Ahh', 'Grito', '2023-11-01 18:00:00', 50);
CALL Agendar_Peca('Dsadas', 'Sdaasda', '2025-09-04 19:00:00', 50);
CALL Agendar_Peca('rei leão', 'um leão que é rei', '2025-09-13 09:00:00', 50);