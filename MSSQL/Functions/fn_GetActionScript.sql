
/****** Object:  UserDefinedFunction [dbo].[fn_GetActionScript]    Script Date: 06/25/2019 3:23:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--sp_EvaluateQueue
-- delete from QueueStepActions
-- Delete from QueueSteps
-- Update Queue Set Status  = 'N'

/*select 
fro m INFORMATION_SCHEMA.COLUMNS
where Table_Name = 'WorkFlowStepActions'
order by TABLE_NAME, ORDINAL_POSITION
Declare @DD as varchar(Max)
exec @DD = dbo.fn_GetActionScript 15, 8
print @DD 

Select 'ssp_CreateTask' + ' ' + cast(isnull(ColumnGlobalCode1,'') as varchar(20)), + ' ' + cast(isnull(ColumnInt1,'') as varchar(20)) + ''', + ' ' + cast(isnull(ColumnInt2,'') as varchar(20)) + ''', + '''' + cast(isnull(ColumnDatetime1,'') as varchar(30)), + '''' + isnull(ColumnText1,'') + '''' From WorkFlowStepActions where WorkFlowStepId = 15

*/

-- =============================================
-- Author:	Ravinder
-- Create date: 27th-June-08
-- Modifi Date: 17th_feb-09
-- Modifi Date: 30th-Mar-11
-- Modifi Date: 29th-May-11
-- Modifi Date: 21st-Apr-12
-- Description:	This function will be used to create the Action Script based on the WorkFlowStepId
-- =============================================
ALTER FUNCTION [dbo].[fn_GetActionScript]( @queuestepactionid AS int )
RETURNS int
AS
BEGIN
	DECLARE @actionscript AS varchar( max );
	DECLARE @workflowaction AS varchar( 500 );
	DECLARE @workflowactionid AS int;
	DECLARE @keyid AS int;
	SET @keyid = -1;
	SET @workflowaction = '';
	SET @actionscript = '';

	DECLARE @datatype AS varchar( 500 );
	DECLARE @parametername AS varchar( 500 );

	DECLARE @varcharcolumnindex AS int;
	DECLARE @textcolumnindex AS int;
	DECLARE @integercolumnindex AS int;
	DECLARE @datecolumnindex AS int;
	DECLARE @moneycolumnindex AS int;
	DECLARE @globalcodecolumnindex AS int;
	DECLARE @workflowstepactionid AS int;
	DECLARE @columnname AS varchar( 256 );
	DECLARE @generalindex AS int;

	SELECT @keyid = Q.KeyId ,
		   @workflowstepactionid = QSA.WorkFlowStepActionId
	  FROM Queue AS Q INNER JOIN QueueSteps AS QS ON Q.QueueId = QS.QueueId
					  INNER JOIN QueueStepActions AS QSA ON QS.QueueStepId = QSA.QueueStepId
	  WHERE QSA.QueueStepActionId = @queuestepactionid;

	--Declare WorkFlowStepActionsCursor Cursor
	--For
	--Select WorkFlowStepActionId from WorkFlowStepActions
	--where WorkFlowStepId = @WorkFlowStepId

	--Checking for errors
	IF(@@error <> 0)
		BEGIN
			RETURN -1
		END;

	--Open WorkFlowStepActionsCursor
	--Fetch Next from WorkFlowStepActionsCursor into  @WorkFlowStepActionId
	--While (@@Fetch_Status = 0) 
	--Begin 

	SELECT @workflowaction = WorkFlowActions.ACTION ,
		   @workflowactionid = WorkFlowActions.WorkFlowActionId
	  FROM WorkFlowStepActions INNER JOIN WorkFlowActions ON WorkFlowStepActions.WorkFlowActionId = WorkFlowActions.WorkFlowActionId
	  WHERE WorkFlowStepActionId = @workflowstepactionid;

	--Set @ActionScript = cast(@WorkFlowActionId as varchar(20)) + ':' + @WorkFlowAction
	SET @actionscript = 'Update QueueStepActions set ActionScript=(Select ''' + @workflowaction;  --+ ' ' + cast(@KeyId as varchar(15)) + ','
	--Set @ActionScript = 'Select ''' + @WorkFlowAction 

	SET @varcharcolumnindex = 0;
	SET @textcolumnindex = 0;
	SET @integercolumnindex = 0;
	SET @datecolumnindex = 0;
	SET @moneycolumnindex = 0;
	SET @globalcodecolumnindex = 0;
	SET @datatype = '';
	SET @parametername = '';
	SET @columnname = '';

	DECLARE WorkFlowActionParametersCursor CURSOR
		FOR SELECT ParaMeterName ,
				   GlobalCodes.CodeName AS DatType
			  FROM WorkFlowActionParameters INNER JOIN GlobalCodes ON WorkFlowActionParameters.DataType = GlobalCodes.GlobalCodeId
			  WHERE WorkFlowActionParameters.WorkFlowActionId = @workflowactionid
				AND WorkFlowActionParameters.RecordDeleted = 'N';

	--Checking for errors
	IF(@@error <> 0)
		BEGIN
			RETURN -1
		END;

	OPEN WorkFlowActionParametersCursor;
	FETCH Next FROM WorkFlowActionParametersCursor INTO @parametername ,@datatype;
	WHILE(@@fetch_status = 0)
		BEGIN
			--Update QueueStepActions set ActionScript=(Select 'ssp_CreateTask ' + '''' + isnull(ColumnVarchar1,'') + ''',' +'''' + isnull(ColumnText1,'') + ''''  From WorkFlowStepActions where WorkFlowStepId = 15) where QueueStepActionId = 8
			--Update QueueStepActions set ActionScript=(Select 'ssp_CreateTask ' + '''' + isnull(ColumnVarchar1,'') + ''', + ' + '''' + isnull(ColumnText1,'') + From WorkFlowStepActions where WorkFlowStepId = 15) where QueueStepActionId = 8

			--exec sp_CreateWorkFlowQueueSteps @QueueId , 'admin', 'admin'
			IF @datatype = 'Text'
				BEGIN
					SET @textcolumnindex = @textcolumnindex + 1;
					SET @columnname = ' '''''' + replace(isnull(ColumnText' + CAST(@textcolumnindex AS varchar( 3 )) + ',''null''),'''''''','''''''''''')' + ' + ''''''';

				END;
			ELSE
				BEGIN
					IF @datatype = 'Varchar'
						BEGIN
							SET @varcharcolumnindex = @varcharcolumnindex + 1;
							SET @columnname = ' '''''' + replace(isnull(ColumnVarchar' + CAST(@varcharcolumnindex AS varchar( 3 )) + ',''null''),'''''''','''''''''''')' + ' + ''''''';
						END;
					ELSE
						BEGIN
							IF @datatype = 'Integer'
								BEGIN
									SET @integercolumnindex = @integercolumnindex + 1;
									SET @columnname = ' ''' + ' + replace(cast(isnull(ColumnInteger' + CAST(@integercolumnindex AS varchar( 3 )) + ',-1) as varchar(20)),-1,''null'')' + ' + ''';
								END;
							ELSE
								BEGIN
									IF @datatype = 'Date'
										BEGIN
											SET @datecolumnindex = @datecolumnindex + 1;
											SET @columnname = ' '''''' + isnull(substring(convert(varchar(13),ColumnDatetime' + CAST(@datecolumnindex AS varchar( 3 )) + ',101),0,12),''null'')' + ' + ''''''';
										END;
									ELSE
										BEGIN
											IF @datatype = 'Money'
												BEGIN
													SET @moneycolumnindex = @moneycolumnindex + 1;
													SET @columnname = ' ''' + ' + replace(cast(isnull(ColumnMoney' + CAST(@moneycolumnindex AS varchar( 3 )) + ',-1) as varchar(20)),-1,''null'')' + ' + ''';
												END;
											ELSE
												BEGIN
													IF @datatype = 'GlobalCode'
														BEGIN
															SET @globalcodecolumnindex = @globalcodecolumnindex + 1;
															SET @columnname = '  ''' + ' + replace(cast(isnull(ColumnGlobalCode' + CAST(@globalcodecolumnindex AS varchar( 3 )) + ',-1) as varchar(20)),-1,''null'')' + ' + ''';
														END
												END
										END
								END
						END
				END;
			SET @actionscript = @actionscript + @columnname + ',';

			FETCH Next FROM WorkFlowActionParametersCursor INTO @parametername ,@datatype;
		END;

	CLOSE WorkFlowActionParametersCursor;
	DEALLOCATE WorkFlowActionParametersCursor;

	SET @actionscript = SUBSTRING( @actionscript ,1 ,LEN( @actionscript ) - 1 );

	SET @actionscript = @actionscript + ',' + CAST(@queuestepactionid AS varchar( 10 )) + ',' + CAST(@keyid AS varchar( 10 )) + ''' From WorkFlowStepActions where WorkFlowStepActionId = ' + CAST(@workflowstepactionid AS varchar( 10 ));

	SET @actionscript = @actionscript + ') where QueueStepActionId = ' + CAST(@queuestepactionid AS varchar( 10 ));
	--set @ActionScript = replace(@ActionScript, '''-$$-''','null')

	DECLARE @statement AS nvarchar( max );
	DECLARE @tempstatement AS nvarchar( max );
	--set @TempStatement = cast('Update QueueStepActions set ActionScript = replace(ActionScript,''''null'''',''''null'''') where QueueStepActionId = ' + cast(@QueueStepActionId as varchar(10))  as varchar(max))
	SET @statement = CAST(@actionscript AS nvarchar( max ));
	SET @tempstatement = CAST('Insert into TempActionScript values(''' + REPLACE( @actionscript ,'''' ,'''''' ) + ''')' AS varchar( max ));
	EXEC sp_ExecuteSQL @statement;
	EXEC sp_ExecuteSQL @tempstatement;

	--Fetch Next from WorkFlowStepActionsCursor into @WorkFlowStepActionId
	--End	
	--
	--Close WorkFlowStepActionsCursor
	--Deallocate WorkFlowStepActionsCursor

	RETURN @@rowcount;
END;










