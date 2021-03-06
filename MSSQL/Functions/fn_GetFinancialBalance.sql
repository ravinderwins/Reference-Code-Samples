
/****** Object:  UserDefinedFunction [dbo].[fn_GetFinancialBalance]    Script Date: 06/25/2019 3:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SELECT * FROM [dbo].[fn_GetFinancialBalance](717)
-- Author:		Ravinder
-- Create date: 8th-Jan-2018
-- Description:	This function will be used to get  financial balance of client by client id.
-- #Bug: 411 
-- =============================================

ALTER FUNCTION [dbo].[fn_GetFinancialBalance](@clientid AS int)
RETURNS @tmpbalances TABLE(ClientProgramEnrollmentId int, Balance decimal(18, 2), Fee decimal(18, 2), Payment decimal(18, 2), Indigence decimal(18, 2), BadDebt decimal(18, 2))
AS
BEGIN

    DECLARE @tmpcurrentbalance decimal(18, 2);

    INSERT INTO @tmpbalances
    SELECT CCFD.ClientProgramEnrollmentId,
           CONVERT(decimal(9, 2), SUM(ccfd.LineItemAmount*CASE
                                                              WHEN gc.CodeName = 'Add'
                                                              THEN 1
                                                              ELSE-1
                                                          END)),
           SUM(CASE
                   WHEN tt.TransactionTypeCF IN('Fee', 'Void Fee', 'Transfer Fee', 'Forfeit')
                   THEN
                       (ccfd.LineItemAmount*CASE
                                                WHEN gc.CodeName = 'Add'
                                                THEN 1
                                                ELSE-1
                                            END
                                               )
                   ELSE 0
               END),
           SUM(CASE
                   WHEN tt.TransactionTypeCF IN('Payment', 'Void Payment', 'Funds Transfer', 'Refund', 'Quick Payment')
                   THEN
                       (ccfd.LineItemAmount*CASE
                                                WHEN gc.CodeName = 'Add'
                                                THEN 1
                                                ELSE-1
                                            END
                                               )
                   ELSE 0
               END),
           SUM(CASE
                   WHEN tt.TransactionTypeCF IN('Indigence')
                   THEN
                       (ccfd.LineItemAmount*CASE
                                                WHEN gc.CodeName = 'Add'
                                                THEN 1
                                                ELSE-1
                                            END
                                               )
                   ELSE 0
               END),
           SUM(CASE
                   WHEN tt.TransactionTypeCF IN('Bad Debt', 'Reinstate Bad Debt')
                   THEN
                       (ccfd.LineItemAmount*CASE
                                                WHEN gc.CodeName = 'Add'
                                                THEN 1
                                                ELSE-1
                                            END
                                               )
                   ELSE 0
               END)
      FROM ClientCommunityFinancials AS CCF
      INNER JOIN ClientCommunityFinancialDetails AS CCFD ON CCF.ClientCommunityFinancialsId = CCFD.ClientCommunityFinancialsId
      INNER JOIN TransactionTypesCF AS tt ON CCF.TransactionTypeCFId = tt.TransactionTypeCFId
      INNER JOIN globalcodes AS gc ON tt.flag = gc.globalcodeid
	 INNER JOIN ClientProgramEnrollments AS CPE ON CCFD.ClientProgramEnrollmentId = CPE.ClientProgramEnrollmentId
	 INNER JOIN Programs AS P ON CPE.ProgramId = P.ProgramId
	 INNER JOIN GlobalCodes AS GC2 ON P.AccountingType = GC2.GlobalCodeId AND GC2.CodeName = 'Community'
     WHERE CCF.ClientId = @clientid
     GROUP BY CCFD.ClientProgramEnrollmentId;


    RETURN;
END;
