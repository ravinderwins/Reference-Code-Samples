USE [subkioskone];
GO

/*************************************************************************************************
***** Object:  StoredProcedure [dbo].[sp_GetKioskData]    Script Date: 06/24/2019 5:07:38 PM *****
*************************************************************************************************/

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/****************************************************************************************************
***** Object:  StoredProcedure [dbo].[sp_GetKioskData]    Script Date: 7/27/2018 5:43:05 PM
   --   Created by	:	Rajeev							 *****
--	    Created Date  :	18 July 2018
	--  Description   :	Fetch all agendas with request status 'Requested' and update status to 'Review'
	-- Modified date: 01-Nov-2018      
	-- Description: Replaced utc function.
	-- Description: 1592 Adjusted for 1592 on 06th June 2019
****************************************************************************************************/

--exec sp_GetKioskData @TableName='CalendarMeetings',@Condition='Agenda',@ClientId=69

ALTER PROCEDURE [dbo].[sp_GetKioskData](@tablename varchar(50), @condition varchar(250)= NULL, @clientid int= -1)
AS
BEGIN
    DECLARE @xmldata nvarchar(max) = '';
    DECLARE @timeoffset nvarchar(6);
    SELECT @timeoffset =
                         (
           SELECT T.current_utc_offset
             FROM sys.time_zone_info AS T
             INNER JOIN CompanyConfigurations AS CC ON CC.Timezone = T.name
                         );

    IF(@tablename = 'ClientEmergencyContacts')
    BEGIN
        SELECT @xmldata =
                          (
               SELECT
                     (
                      SELECT Rex.Id, 
                             Rex.ClientId, 
                             Rex.Name, 
                             Rex.ClientVehicleId, 
                             Rex.RecordDeleted
                        FROM ClientContacts AS Rex
                       WHERE Rex.ClientId = @clientid FOR XML PATH('ClientEmergencyContacts')
                     ) FOR XML PATH('MainDataSet')
                          );
    END;
        ELSE
    BEGIN
        IF(@tablename = 'ClientGroupRegistrations')
        BEGIN
            SELECT @xmldata =
                              (
                   SELECT
                         (
                          SELECT Rex.Id, 
                                 Rex.ClientId, 
                                 Rex.TreatmentGroupId, 
                                 Rex.RecordDeleted, 
                                 CAST(StartDate AS date) AS StartDate, 
                                 CAST(EndDate AS date) AS EndDate
                            FROM ClientTreatmentGroups AS Rex
                           WHERE Rex.ClientId = @clientid FOR XML PATH('ClientGroupRegistrations')
                         ) FOR XML PATH('MainDataSet')
                              );
        END;
            ELSE
        BEGIN
            IF(@tablename = 'ClientVehicles')
            BEGIN
                SELECT @xmldata =
                                  (
                       SELECT
                             (
                              SELECT Rex.Id, 
                                     Rex.ClientId, 
                                     Rex.VehicleDescription, 
                                     Rex.RecordDeleted
                                FROM ClientVehicles AS Rex
                               WHERE Rex.ClientId = @clientid FOR XML PATH('ClientVehicles')
                             ) FOR XML PATH('MainDataSet')
                                  );
            END;
                ELSE
            BEGIN
                IF(@tablename = 'ClientJobHistory')
                BEGIN
                    SELECT @xmldata =
                                      (
                           SELECT
                                 (
                                  SELECT Id, 
                                         Rex.EmployerId, 
                                         Rex.ClientId, 
                                         Rex.StartDate, 
                                         Rex.EndDate, 
                                         Rex.RecordDeleted
                                    FROM ClientEmployers AS Rex
                                   WHERE Rex.ClientId = @clientid FOR XML PATH('ClientJobHistory')
                                 ) FOR XML PATH('MainDataSet')
                                      );
                END;
                    ELSE
                BEGIN
                    IF(@tablename = 'CalendarMeetings')
                    BEGIN
                        SELECT @xmldata =
                                          (
                               SELECT
                                     (
                                      SELECT Rex.MeetingId AS Id, 
                                             Rex.ClientId, 
                                             Rex.MeetingType, 
                                             Rex.Title, 
                                             CONVERT(datetime, SWITCHOFFSET(Rex.StartTime, @timeoffset), 0) AS StartTime, 
                                             CONVERT(datetime, SWITCHOFFSET(Rex.EndTime, @timeoffset), 0) AS EndTime, 
                                             Rex.RecordDeleted, 
                                             Rex.MasterReference, 
                                             Rex.CalendarId
                                        FROM ClientMeetings AS Rex
                                       WHERE Rex.ClientId = @clientid FOR XML PATH('CalendarMeetings')
                                     ) FOR XML PATH('MainDataSet')
                                          );
                    END;
                        ELSE
                    BEGIN
                        IF(@tablename = 'ClientPassSites')
                        BEGIN
                            SELECT @xmldata =
                                              (
                                   SELECT
                                         (
                                          SELECT Rex.Id AS Id, 
                                                 Rex.ClientId, 
                                                 Rex.PassSite, 
                                                 Rex.DestinationType, 
                                                 Rex.ContactName, 
                                                 Rex.Address, 
                                                 Rex.PhoneNumber, 
                                                 Rex.RecordDeleted
                                            FROM ClientPassSites AS Rex
                                           WHERE Rex.ClientId = @clientid FOR XML PATH('ClientPassSites')
                                         ) FOR XML PATH('MainDataSet')
                                              );
                        END;
                            ELSE
                        BEGIN
                            IF(@tablename = 'ClientResidentFinancialAccountDetails')
                            BEGIN
                                SELECT @xmldata =
                                                  (
                                       SELECT
                                             (
                                              SELECT Rex.ClientResidentFinancialAccountDetailId AS Id, 
                                                     Rex.ClientResidentFinancialAccountId, 
                                                     Rex.TransactionDate, 
                                                     Rex.TransactionTypeRFId, 
                                                     Rex.TransactionAmount, 
                                                     Rex.EmployerId, 
                                                     Rex.CheckDate, 
                                                     Rex.PayPeriod, 
                                                     Rex.PayPeriodStartDate, 
                                                     Rex.PayPeriodEndDate, 
                                                     Rex.GrossPay, 
                                                     Rex.NetPay, 
                                                     Rex.HoursWorked, 
                                                     Rex.Tips, 
                                                     Rex.Payee, 
                                                     Rex.AdditionalPayeeInfo, 
                                                     Rex.CheckMemo, 
                                                     Rex.PrintCheck, 
                                                     Rex.Emergency, 
                                                     Rex.TransferFromAccountType, 
                                                     Rex.TransferFromAccount, 
                                                     Rex.TransferToAccountType, 
                                                     Rex.TransferToAccount, 
                                                     Rex.Comments, 
                                                     Rex.RecordDeleted, 
                                                     Rex.CheckPrinted
                                                FROM ClientResidentFinancialAccountDetails AS Rex
                                                INNER JOIN ClientResidentFinancialAccounts AS CFA ON Rex.ClientResidentFinancialAccountId = CFA.ClientResidentFinancialAccountId
                                               WHERE CFA.ClientId = @clientid FOR XML PATH('ClientResidentFinancialAccountDetails')
                                             ) FOR XML PATH('MainDataSet')
                                                  );
                            END;
                                ELSE
                            BEGIN
                                IF(@tablename = 'ClientResidentFinancialAccounts')
                                BEGIN
                                    SELECT @xmldata =
                                                      (
                                           SELECT
                                                 (
                                                  SELECT Rex.ClientResidentFinancialAccountId AS Id, 
                                                         Rex.ClientId, 
                                                         Rex.ResidentFinancialAccountTypeId, 
                                                         Rex.AccountDescription, 
                                                         Rex.CurrentBalance, 
                                                         Rex.OpenDate, 
                                                         Rex.CloseDate
                                                    FROM ClientResidentFinancialAccounts AS Rex
                                                   WHERE Rex.ClientId = @clientid FOR XML PATH('ClientResidentFinancialAccounts')
                                                 ) FOR XML PATH('MainDataSet')
                                                      );
                                END;
                                    ELSE
                                BEGIN
                                    IF(@tablename = 'KioskClientReminder')
                                    BEGIN
                                        SELECT @xmldata =
                                                          (
                                               SELECT
                                                     (
                                                      SELECT Rex.Id AS Id, 
                                                             Rex.ClientId, 
                                                             Rex.TaskDescription, 
                                                             Rex.Comments, 
                                                             Rex.DueDate, 
                                                             Rex.Completed
                                                        FROM ClientTasks AS Rex
                                                       WHERE Rex.ClientId = @clientid FOR XML PATH('KioskClientReminder')
                                                     ) FOR XML PATH('MainDataSet')
                                                          );
                                    END;
                                        ELSE
                                    BEGIN
                                        IF(@tablename = 'KioskProfiles')
                                        BEGIN
                                            SELECT @xmldata =
                                                              (
                                                   SELECT
                                                         (
                                                          SELECT Rex.ClientId AS Id, 
                                                                 Rex.ClientId, 
                                                                 Rex.PhaseId, 
                                                                 Rex.UserName
                                                            FROM AspNetUsers AS Rex
                                                           WHERE Rex.ClientId = @clientid FOR XML PATH('KioskProfiles')
                                                         ) FOR XML PATH('MainDataSet')
                                                              );
                                        END;
                                            ELSE
                                        BEGIN
                                            IF(@tablename = 'Leaves')
                                            BEGIN
                                                SELECT @xmldata =
                                                                  (
                                                       SELECT
                                                             (
                                                              SELECT Rex.ClientLeaveId, 
                                                                     Rex.ClientId, 
                                                                     Rex.LeaveType, 
                                                                     CONVERT(datetime, SWITCHOFFSET(ScheduledDeparture, @timeoffset), 0) AS ScheduledDeparture, 
                                                                     Rex.DepartTransMode, 
                                                                     Rex.DepartTransDetails, 
                                                                     Rex.DepartTransDriver, 
                                                                     Rex.DepartTransVehicle, 
                                                                     Rex.DepartTravelTime, 
                                                                     CONVERT(datetime, SWITCHOFFSET(ScheduledReturn, @timeoffset), 0) AS ScheduledReturn, 
                                                                     Rex.ReturnTransMode, 
                                                                     Rex.ReturnTransDetails, 
                                                                     Rex.ReturnTransDriver, 
                                                                     Rex.ReturnTransVehicle, 
                                                                     Rex.ReturnTravelTime, 
                                                                     Rex.RecordDeleted, 
                                                                     Rex.Comments
                                                                FROM ClientLeaves AS Rex
                                                               WHERE Rex.ClientId = @clientid
                                                                     AND ISNULL(ClientLeaveId, -1) > 0 FOR XML PATH('ClientLeaves')
                                                             ) FOR XML PATH('MainDataSet')
                                                                  );
                                            END;
                                                ELSE
                                            BEGIN
                                                IF(@tablename = 'LeaveSchedules')
                                                BEGIN
                                                    SELECT @xmldata =
                                                                      (
                                                           SELECT
                                                                 (
                                                                  SELECT Rex.ClientLeaveScheduleId AS ClientLeaveScheduleId, 
                                                                         CL.ClientId, 
                                                                         CL.ClientLeaveId, 
                                                                         Rex.ScheduleType, 
                                                                         Rex.ScheduleDestinationKey, 
                                                                         CONVERT(datetime, SWITCHOFFSET(Rex.StartDate, @timeoffset), 0) AS StartDate, 
                                                                         CONVERT(datetime, SWITCHOFFSET(Rex.EndDate, @timeoffset), 0) AS EndDate, 
                                                                         Rex.ReturnsToCenter, 
                                                                         Rex.InterimTransMode, 
                                                                         Rex.InterimTransDetails, 
                                                                         Rex.InterimTransDriver, 
                                                                         Rex.InterimTransVehicle, 
                                                                         Rex.InterimTravelTime, 
                                                                         Rex.RecordDeleted, 
                                                                         Rex.DestinationType, 
                                                                         Rex.Comments
                                                                    FROM ClientLeaveSchedules AS Rex
                                                                    INNER JOIN ClientLeaves AS CL ON Rex.ClientLeaveId = CL.Id
                                                                   WHERE CL.ClientId = @clientid
                                                                         AND ISNULL(CL.ClientLeaveId, -1) > 0 FOR XML PATH('ClientLeaveSchedules')
                                                                 ) FOR XML PATH('MainDataSet')
                                                                      );
                                                END;
                                                    ELSE
                                                BEGIN
                                                    IF(@tablename = 'Agenda')
                                                    BEGIN
                                                        --SELECT @xmldata =
                                                        --                  (
                                                        --       SELECT
                                                        --             (
                                                        --              SELECT CL.Id, 
                                                        --                     ClientId, 
                                                        --                     LeaveType, 
                                                        --                     CONVERT(datetime, SWITCHOFFSET(ScheduledDeparture, @timeoffset), 0) AS ScheduledDeparture, 
                                                        --                     DepartTransMode, 
                                                        --                     DepartTransDriver, 
                                                        --                     DepartTransVehicle, 
                                                        --                     DepartTravelTime, 
                                                        --                     CONVERT(datetime, SWITCHOFFSET(ScheduledReturn, @timeoffset), 0) AS ScheduledReturn, 
                                                        --                     ReturnTransMode, 
                                                        --                     ReturnTransDetails, 
                                                        --                     ReturnTransDriver, 
                                                        --                     ReturnTransVehicle, 
                                                        --                     ReturnTravelTime, 
                                                        --                     ClientLeaveId, 
                                                        --                     Comments, 
                                                        --                     RequestStatus, 
                                                        --                     gc.CodeName AS AgendaStatus, 
                                                        --                     DenialReason
                                                        --                FROM ClientLeaves AS CL
                                                        --                INNER JOIN GlobalCodes AS GC ON CL.RequestStatus = GC.Id
                                                        --               WHERE CL.ClientId = @clientid
                                                        --                     AND ISNULL(CL.ClientLeaveId, '') = '' --AND ScheduledDeparture >= CAST(GETDATE() AS DATE)
                                                        --              FOR XML PATH('Agenda')
                                                        --             ) FOR XML PATH('MainDataSet')
                                                        --                  );
                                                        SET @xmldata =
                                                                       (
                                                            SELECT
                                                                  (
                                                                   (
                                                                   SELECT CL.Id, 
                                                                          ClientId, 
                                                                          LeaveType, 
                                                                          CONVERT(datetime, SWITCHOFFSET(ScheduledDeparture, @timeoffset), 0) AS ScheduledDeparture,
                                                                          -- dbo.fn_ConvertUtcDateTimeLocalDateTime(ScheduledDeparture) AS ScheduledDeparture,
                                                                          DepartTransMode, 
                                                                          DepartTransDetails, 
                                                                          DepartTransDriver, 
                                                                          DepartTransVehicle, 
                                                                          DepartTravelTime, 
                                                                          CONVERT(datetime, SWITCHOFFSET(ScheduledReturn, @timeoffset), 0) AS ScheduledReturn,
                                                                          --dbo.fn_ConvertUtcDateTimeLocalDateTime(ScheduledReturn) AS ScheduledReturn,
                                                                          ReturnTransMode, 
                                                                          ReturnTransDetails, 
                                                                          ReturnTransDriver, 
                                                                          ReturnTransVehicle, 
                                                                          ReturnTravelTime, 
                                                                          CL.RecordDeleted, 
                                                                          RequestStatus, 
                                                                          GC.CodeName AS AgendaStatus, 
                                                                          ClientLeaveId, 
                                                                          DenialReason, 
                                                                          Comments
                                                                   --  FROM CLIENTLEAVES
                                                                     FROM ClientLeaves AS CL
                                                                     INNER JOIN GlobalCodes AS GC ON CL.RequestStatus = GC.Id
                                                                    WHERE CL.ClientId = @clientid
                                                                          AND ISNULL(CL.ClientLeaveId, '') = '' --AND ScheduledDeparture >= CAST(GETDATE() AS DATE)
                                                                   FOR XML PATH('ClientLeaves')
                                                                   )
                                                                  ), 
                                                                  (
                                                                   SELECT cl.ClientLeaveId AS TomClientLeaveId, 
                                                                          cls.Id, 
                                                                          cls.ClientLeaveId, 
                                                                          cls.ScheduleType, 
                                                                          cls.ScheduleDestinationKey, 
                                                                          CONVERT(datetime, SWITCHOFFSET(cls.StartDate, @timeoffset), 0) AS StartDate, 
                                                                          CONVERT(datetime, SWITCHOFFSET(cls.EndDate, @timeoffset), 0) AS EndDate,
                                                                          --dbo.fn_ConvertUtcDateTimeLocalDateTime(cls.StartDate) AS StartDate,
                                                                          --dbo.fn_ConvertUtcDateTimeLocalDateTime(cls.EndDate) AS EndDate,
                                                                          cls.ReturnsToCenter, 
                                                                          cls.InterimTransMode, 
                                                                          cls.InterimTransDetails, 
                                                                          cls.InterimTransDriver, 
                                                                          cls.InterimTransVehicle, 
                                                                          cls.InterimTravelTime, 
                                                                          cls.RecordDeleted, 
                                                                          cls.DestinationType, 
                                                                          cls.Comments
                                                                     FROM CLIENTLEAVESCHEDULES AS cls
                                                                     INNER JOIN ClientLeaves AS cl ON cls.ClientLeaveId = cl.Id
                                                                    WHERE --ISNULL(cls.RecordDeleted, 'N') = 'N'
                                                                    --AND ISNULL(cl.RecordDeleted, 'N') = 'N'
                                                                    CL.ClientId = @clientid
                                                                    AND ISNULL(CL.ClientLeaveId, '') = ''
                                                                   --AND RequestStatus IN
                                                                   --                    (
                                                                   --                     SELECT Id
                                                                   --                       FROM GlobalCodes
                                                                   --                      WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                   --                            AND CodeName = 'Requested'
                                                                   --                    ) 
                                                                   FOR XML PATH('ClientLeaveSchedules')
                                                                  ) FOR XML PATH('MainDataSet')
                                                                       );

                                                        --   SELECT @xmldata = REPLACE(REPLACE(@xmldata, '&lt;', '<'), '&gt;', '>');

                                                        UPDATE CLIENTLEAVES
                                                          SET 
                                                              RequestStatus =
                                                                              (
                                                              SELECT TOP 1 Id
                                                                FROM GlobalCodes
                                                               WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                     AND CodeName = 'Review'
                                                                              )
                                                         WHERE RequestStatus IN
                                                                               (
                                                                                SELECT Id
                                                                                  FROM GlobalCodes
                                                                                 WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                                       AND CodeName = 'Requested'
                                                                               );
                                                    END;
                                                        ELSE
                                                    BEGIN
                                                        IF(@tablename = 'AgendaSchedule')
                                                        BEGIN

                                                            SELECT @xmldata =
                                                                              (
                                                                   SELECT
                                                                         (
                                                                          SELECT Rex.Id, 
                                                                                 CL.ClientId, 
                                                                                 CL.Id AS ClientLeaveId, 
                                                                                 Rex.ScheduleType, 
                                                                                 Rex.ScheduleDestinationKey, 
                                                                                 CONVERT(datetime, SWITCHOFFSET(StartDate, @timeoffset), 0) AS StartDate, 
                                                                                 CONVERT(datetime, SWITCHOFFSET(EndDate, @timeoffset), 0) AS EndDate, 
                                                                                 Rex.ReturnsToCenter, 
                                                                                 Rex.InterimTransMode, 
                                                                                 Rex.InterimTransDetails, 
                                                                                 Rex.InterimTransDriver, 
                                                                                 Rex.InterimTransVehicle, 
                                                                                 Rex.InterimTravelTime, 
                                                                                 Rex.RecordDeleted, 
                                                                                 Rex.DestinationType, 
                                                                                 Rex.Comments
                                                                            FROM ClientLeaveSchedules AS Rex
                                                                            INNER JOIN ClientLeaves AS CL ON Rex.ClientLeaveId = CL.Id
                                                                           WHERE CL.ClientId = @clientid
                                                                                 AND ISNULL(CL.ClientLeaveId, '') = '' FOR XML PATH('ClientLeaveSchedules')
                                                                         ) FOR XML PATH('MainDataSet')
                                                                              );
                                                        END;
                                                            ELSE
                                                        BEGIN
                                                            SET @xmldata =
                                                                           (
                                                                SELECT
                                                                      (
                                                                       (
                                                                       SELECT Id, 
                                                                              ClientId, 
                                                                              LeaveType, 
                                                                              CONVERT(datetime, SWITCHOFFSET(ScheduledDeparture, @timeoffset), 0) AS ScheduledDeparture,
                                                                              -- dbo.fn_ConvertUtcDateTimeLocalDateTime(ScheduledDeparture) AS ScheduledDeparture,
                                                                              DepartTransMode, 
                                                                              DepartTransDetails, 
                                                                              DepartTransDriver, 
                                                                              DepartTransVehicle, 
                                                                              DepartTravelTime, 
                                                                              CONVERT(datetime, SWITCHOFFSET(ScheduledReturn, @timeoffset), 0) AS ScheduledReturn,
                                                                              --dbo.fn_ConvertUtcDateTimeLocalDateTime(ScheduledReturn) AS ScheduledReturn,
                                                                              ReturnTransMode, 
                                                                              ReturnTransDetails, 
                                                                              ReturnTransDriver, 
                                                                              ReturnTransVehicle, 
                                                                              ReturnTravelTime, 
                                                                              RecordDeleted, 
                                                                              RequestStatus, 
                                                                              ClientLeaveId, 
                                                                              DenialReason, 
                                                                              Comments
                                                                         FROM CLIENTLEAVES
                                                                        WHERE RequestStatus IN
                                                                                              (
                                                                                               SELECT Id
                                                                                                 FROM GlobalCodes
                                                                                                WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                                                      AND CodeName = 'Requested'
                                                                                              ) FOR XML PATH('ClientLeaves')
                                                                       )
                                                                      ), 
                                                                      (
                                                                       SELECT cl.ClientLeaveId AS TomClientLeaveId, 
                                                                              cls.Id, 
                                                                              cls.ClientLeaveId, 
                                                                              cls.ScheduleType, 
                                                                              cls.ScheduleDestinationKey, 
                                                                              CONVERT(datetime, SWITCHOFFSET(cls.StartDate, @timeoffset), 0) AS StartDate, 
                                                                              CONVERT(datetime, SWITCHOFFSET(cls.EndDate, @timeoffset), 0) AS EndDate,
                                                                              --dbo.fn_ConvertUtcDateTimeLocalDateTime(cls.StartDate) AS StartDate,
                                                                              --dbo.fn_ConvertUtcDateTimeLocalDateTime(cls.EndDate) AS EndDate,
                                                                              cls.ReturnsToCenter, 
                                                                              cls.InterimTransMode, 
                                                                              cls.InterimTransDetails, 
                                                                              cls.InterimTransDriver, 
                                                                              cls.InterimTransVehicle, 
                                                                              cls.InterimTravelTime, 
                                                                              cls.RecordDeleted, 
                                                                              cls.DestinationType, 
                                                                              cls.Comments
                                                                         FROM CLIENTLEAVESCHEDULES AS cls
                                                                         INNER JOIN ClientLeaves AS cl ON cls.ClientLeaveId = cl.Id
                                                                        WHERE ISNULL(cls.RecordDeleted, 'N') = 'N'
                                                                              AND ISNULL(cl.RecordDeleted, 'N') = 'N'
                                                                              AND RequestStatus IN
                                                                                                  (
                                                                                                   SELECT Id
                                                                                                     FROM GlobalCodes
                                                                                                    WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                                                          AND CodeName = 'Requested'
                                                                                                  ) FOR XML PATH('ClientLeaveSchedules')
                                                                      ) FOR XML PATH('MainDataSet')
                                                                           );

                                                            SELECT @xmldata = REPLACE(REPLACE(@xmldata, '&lt;', '<'), '&gt;', '>');

                                                            UPDATE CLIENTLEAVES
                                                              SET 
                                                                  RequestStatus =
                                                                                  (
                                                                  SELECT TOP 1 Id
                                                                    FROM GlobalCodes
                                                                   WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                         AND CodeName = 'Review'
                                                                                  )
                                                             WHERE RequestStatus IN
                                                                                   (
                                                                                    SELECT Id
                                                                                      FROM GlobalCodes
                                                                                     WHERE CategoryName LIKE 'KioskLeaveRequestStatus'
                                                                                           AND CodeName = 'Requested'
                                                                                   );
                                                        END;
                                                    END;
                                                END;
                                            END;
                                        END;
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;
            END;
        END;
    END;

    SELECT @xmldata = REPLACE(REPLACE(@xmldata, '&lt;', '<'), '&gt;', '>');
    SELECT @xmldata;
END;