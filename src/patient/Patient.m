classdef Patient
    %PATIENT Immutable demographic record shared by all PK/PD models.
    %   p = Patient(id, age, height, weight, sex)
    %       age [years], height [cm], weight [kg], sex 'M' or 'F'.
    %   BMI and lean body mass (James formula) are derived once, so every
    %   model sees one consistent set of covariates.

    properties (SetAccess = immutable)
        id
        age     % years
        height  % cm
        weight  % kg
        sex     % 'M' or 'F'
        bmi     % kg/m^2
        lbm     % kg, James formula
    end

    methods
        function obj = Patient(id, age, height, weight, sex)
            if nargin == 0
                return
            end
            obj.id = id;
            obj.age = age;
            obj.height = height;
            obj.weight = weight;
            obj.sex = Patient.parseSex(sex);
            obj.bmi = weight / (height / 100)^2;
            if obj.sex == 'F'
                obj.lbm = 1.07 * weight - 148 * (weight / height)^2;
            else
                obj.lbm = 1.10 * weight - 128 * (weight / height)^2;
            end
        end

        function tf = isMale(obj)
            tf = obj.sex == 'M';
        end
    end

    methods (Static)
        function obj = fromVitalDbStruct(s)
            %FROMVITALDBSTRUCT Patient(s) from VitalDB clinical-information rows.
            if numel(s) > 1
                obj = repmat(Patient(), numel(s), 1);
                for k = 1:numel(s)
                    obj(k) = Patient.fromVitalDbStruct(s(k));
                end
                return
            end
            required = {'caseid', 'age', 'height', 'weight', 'sex'};
            for f = required
                if ~isfield(s, f{1})
                    error('anesthesim:Patient:missingField', ...
                        'Field "%s" missing in VitalDB record.', f{1});
                end
            end
            obj = Patient(s.caseid, s.age, s.height, s.weight, s.sex);
        end

        function obj = fromTable(T)
            %FROMTABLE Patients from a table with PatientNo, Age, Height, Weight, Sex.
            obj = repmat(Patient(), height(T), 1);
            for k = 1:height(T)
                obj(k) = Patient(T.PatientNo(k), T.Age(k), T.Height(k), T.Weight(k), T.Sex(k));
            end
        end
    end

    methods (Static, Access = private)
        function c = parseSex(sex)
            if iscell(sex)
                sex = sex{1};
            end
            sex = upper(strtrim(char(sex)));
            if isempty(sex) || ~ismember(sex(1), 'MF')
                warning('anesthesim:Patient:unknownSex', ...
                    'Unknown sex "%s"; male covariate formulas are used.', sex);
                c = 'M';
            else
                c = sex(1);
            end
        end
    end
end
