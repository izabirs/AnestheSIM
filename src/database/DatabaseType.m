classdef DatabaseType
    %DATABASETYPE Patient repositories that an acquisition call can target.
    %   Adding a database: add a member here, implement its loader and a
    %   Patient factory, and add a case to loadPatientCase.

    enumeration
        VitalDB     % open surgical database, https://vitaldb.net
        Population  % synthetic demographic records (no recorded signals)
    end
end
