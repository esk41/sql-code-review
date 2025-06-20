CREATE PROCEDURE dbo.usp_ImportFileCustomerSeasonal
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @rowCount INT = 0,
        @errorMessage VARCHAR(4000),
        @errorSeverity INT = 16,
        @errorState INT = 1;

    BEGIN TRY
        IF OBJECT_ID('tempdb..#CustomerSeasonal') IS NOT NULL DROP TABLE #CustomerSeasonal;

        SELECT 
            CAST(ISNULL(cs.FlagActive, 0) AS BIT) AS isActive,
            cs.CustomerCode,
            cs.SeasonCode,
            cs.StartDate,
            cs.EndDate
        INTO #CustomerSeasonal
        FROM staging.CustomerSeasonal AS cs;

        INSERT INTO syn.CustomerSeasonal (CustomerCode, SeasonCode, StartDate, EndDate, IsActive)
        SELECT 
            CustomerCode, SeasonCode, StartDate, EndDate, isActive
        FROM #CustomerSeasonal;

        SET @rowCount = @@ROWCOUNT;

        PRINT 'Загружено строк: ' + CAST(@rowCount AS VARCHAR);

        IF OBJECT_ID('tempdb..#CustomerSeasonal') IS NOT NULL DROP TABLE #CustomerSeasonal;
    END TRY
    BEGIN CATCH
        SET @errorMessage = ERROR_MESSAGE();
        RAISERROR(@errorMessage, @errorSeverity, @errorState);
    END CATCH
END;