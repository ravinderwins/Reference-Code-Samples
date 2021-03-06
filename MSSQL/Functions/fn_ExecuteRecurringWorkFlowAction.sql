
/***********************************************************************************************************************
***** Object:  UserDefinedFunction [dbo].[fn_ExecuteRecurringWorkFlowAction]    Script Date: 06/25/2019 3:24:59 PM *****
***********************************************************************************************************************/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO
-- Drop Function fn_ExecuteRecurringWorkFlowAction
-- ==========================================================================================
-- Author:	Ravinder
-- Modifi Date: 11th-Dec-18
-- Description:	This function will be used to create Script based on Recurring WorkFlow Step Action
-- ==========================================================================================

ALTER FUNCTION [dbo].[fn_ExecuteRecurringWorkFlowAction](@recurringworkflowstepactionid AS int, @recurringworkflowactionid AS int, @keyvalue AS int, @executableworkflowkeyrecordid AS int)
RETURNS varchar(max)
AS
BEGIN
    DECLARE @actionscript AS varchar(max);
    DECLARE @recurringworkflowaction AS varchar(500);

    SET @recurringworkflowaction = '';
    SET @actionscript = '';

    DECLARE @datatype AS varchar(500);
    DECLARE @parametername AS varchar(500);

    DECLARE @varcharcolumnindex AS int;
    DECLARE @textcolumnindex AS int;
    DECLARE @integercolumnindex AS int;
    DECLARE @datecolumnindex AS int;
    DECLARE @moneycolumnindex AS int;
    DECLARE @globalcodecolumnindex AS int;
    DECLARE @columnname AS varchar(256);
    DECLARE @generalindex AS int;
    DECLARE @recurringworkflowtypeid AS int;

    DECLARE @tempactionscript TABLE(Script varchar(max));

    SET @varcharcolumnindex = 0;
    SET @textcolumnindex = 0;
    SET @integercolumnindex = 0;
    SET @datecolumnindex = 0;
    SET @moneycolumnindex = 0;
    SET @globalcodecolumnindex = 0;
    SET @datatype = '';
    SET @parametername = '';
    SET @columnname = '';
    SET @recurringworkflowtypeid = -1;

    SELECT @recurringworkflowaction = ACTION
      FROM RecurringWorkFlowActions
     WHERE RecurringWorkFlowActionId = @recurringworkflowactionid;

    SELECT @recurringworkflowtypeid = RWF.RecurringWorkFlowTypeId
      FROM RecurringWorkFlows AS RWF
      INNER JOIN RecurringWorkFlowStepActions AS RWFSA ON RWF.RecurringWorkFlowId = RWFSA.RecurringWorkFlowId
     WHERE RWFSA.RecurringWorkFlowStepActionId = @recurringworkflowstepactionid;

    --Set @ActionScript = cast(@RecurringWorkFlowActionId as varchar(20)) + ':' + @RecurringWorkFlowAction
    SET @actionscript = 'Update ##ExecutableWorkFlowKeyRecords Set ActionScript=(Select ''' + @recurringworkflowaction;  --+ ' ' + cast(@KeyId as varchar(15)) + ','
    --Set @ActionScript = 'Select ''' + @RecurringWorkFlowAction 

    DECLARE RecurringWorkFlowActionParametersCursor CURSOR
    FOR SELECT ParaMeterName, 
               GlobalCodes.CodeName AS DatType
          FROM RecurringWorkFlowActionParameters
          INNER JOIN GlobalCodes ON RecurringWorkFlowActionParameters.DataType = GlobalCodes.GlobalCodeId
         WHERE RecurringWorkFlowActionParameters.RecurringWorkFlowActionId = @recurringworkflowactionid
               AND RecurringWorkFlowActionParameters.RecordDeleted = 'N';

    --Checking for errors
    IF(@@error <> 0)
    BEGIN
        RETURN -1;
    END;

    OPEN RecurringWorkFlowActionParametersCursor;
    FETCH NEXT FROM RecurringWorkFlowActionParametersCursor INTO @parametername, 
                                                                 @datatype;
    WHILE(@@fetch_status = 0)
    BEGIN
        --Update QueueStepActions set ActionScript=(Select 'ssp_CreateTask ' + '''' + isnull(ColumnVarchar1,'') + ''',' +'''' + isnull(ColumnText1,'') + ''''  From RecurringWorkFlowStepActions where WorkFlowStepId = 15) where QueueStepActionId = 8
        --Update QueueStepActions set ActionScript=(Select 'ssp_CreateTask ' + '''' + isnull(ColumnVarchar1,'') + ''', + ' + '''' + isnull(ColumnText1,'') + From RecurringWorkFlowStepActions where WorkFlowStepId = 15) where QueueStepActionId = 8
        --exec sp_CreateWorkFlowQueueSteps @QueueId , 'admin', 'admin'
        IF @datatype = 'Text'
        BEGIN
            SET @textcolumnindex = @textcolumnindex + 1;
            SET @columnname = ' '''''' + replace(isnull(ColumnText' + CAST(@textcolumnindex AS varchar(3)) + ',''null''),'''''''','''''''''''')' + ' + ''''''';
        END;
            ELSE
        BEGIN
            IF @datatype = 'Varchar'
            BEGIN
                SET @varcharcolumnindex = @varcharcolumnindex + 1;
                SET @columnname = ' '''''' + replace(isnull(ColumnVarchar' + CAST(@varcharcolumnindex AS varchar(3)) + ',''null''),'''''''','''''''''''')' + ' + ''''''';
            END;
                ELSE
            BEGIN
                IF @datatype = 'Integer'
                BEGIN
                    SET @integercolumnindex = @integercolumnindex + 1;
                    --Set @ColumnName =' ColumnInt' + cast(@IntegerColumnIndex as varchar(3))
                    SET @columnname = ' ''' + ' + replace(cast(isnull(ColumnInteger' + CAST(@integercolumnindex AS varchar(3)) + ',-1) as varchar(20)),-1,''null'')' + ' + ''';
                END;
                    ELSE
                BEGIN
                    IF @datatype = 'Date'
                    BEGIN
                        SET @datecolumnindex = @datecolumnindex + 1;
                        SET @columnname = ' '''''' + isnull(substring(convert(varchar(13),ColumnDatetime' + CAST(@datecolumnindex AS varchar(3)) + ',101),0,12),''null'')' + ' + ''''''';
                    END;
                        ELSE
                    BEGIN
                        IF @datatype = 'Money'
                        BEGIN
                            SET @moneycolumnindex = @moneycolumnindex + 1;
                            SET @columnname = ' ''' + ' + replace(cast(isnull(ColumnMoney' + CAST(@moneycolumnindex AS varchar(3)) + ',-1) as varchar(20)),-1,''null'')' + ' + ''';
                        END;
                            ELSE
                        BEGIN
                            IF @datatype = 'GlobalCode'
                            BEGIN
                                SET @globalcodecolumnindex = @globalcodecolumnindex + 1;
                                SET @columnname = '  ''' + ' + replace(cast(isnull(ColumnGlobalCode' + CAST(@globalcodecolumnindex AS varchar(3)) + ',-1) as varchar(20)),-1,''null'')' + ' + ''';
                            END;
                        END;
                    END;
                END;
            END;
        END;
        SET @actionscript = @actionscript + @columnname + ',';

        FETCH NEXT FROM RecurringWorkFlowActionParametersCursor INTO @parametername, 
                                                                     @datatype;
    END;

    CLOSE RecurringWorkFlowActionParametersCursor;
    DEALLOCATE RecurringWorkFlowActionParametersCursor;

    SET @actionscript = SUBSTRING(@actionscript, 1, LEN(@actionscript) - 1);

    SET @actionscript = @actionscript + ',' + CAST(@keyvalue AS varchar(10)) + ',' + CAST(@recurringworkflowtypeid AS varchar(10)) + ',' + CAST(@recurringworkflowstepactionid AS varchar(10)) + ''' From RecurringWorkFlowStepActions where RecurringWorkFlowStepActionId = ' + CAST(@recurringworkflowstepactionid AS varchar(10));

    SET @actionscript = @actionscript + ') where Id = ' + CAST(@executableworkflowkeyrecordid AS varchar(10));
    --print @ActionScript
    --set @ActionScript = replace(@ActionScript, '''-$$-''','null')

    DECLARE @statement AS nvarchar(max);
    DECLARE @tempstatement AS nvarchar(max);
    --set @TempStatement = cast('Update QueueStepActions set ActionScript = replace(ActionScript,''''null'''',''''null'''') where QueueStepActionId = ' + cast(@QueueStepActionId as varchar(10))  as varchar(max))
    SET @statement = CAST(@actionscript AS nvarchar(max));
    SET @tempstatement = CAST('Insert into TempActionScript values(''' + REPLACE(@actionscript, '''', '''''') + ''')' AS varchar(max));
    EXEC sp_ExecuteSQL 
         @statement;
    EXEC sp_ExecuteSQL 
         @tempstatement;

    RETURN @statement;
END;