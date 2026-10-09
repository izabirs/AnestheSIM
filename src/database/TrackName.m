classdef TrackName
    %TRACKNAME Canonical physiological quantities requested by the simulator.
    %   The string payload is the base channel name used by VitalSignal to
    %   build repository-specific channel strings.

    enumeration
        PROP20  ('PPF20')       % propofol, 20 mg/mL pump solution
        REMI20  ('RFTN20')      % remifentanil, 20 ug/mL pump solution
        REMI50  ('RFTN50')      % remifentanil, 50 ug/mL pump solution
        NEPI    ('NEPI_RATE')   % norepinephrine infusion rate
        BIS     ('BIS')         % bispectral index
        SQI     ('SQI')         % BIS signal quality index [%]
        MAP     ('ART_MBP')     % invasive mean arterial pressure
        HR      ('HR')          % heart rate
        SEVO    ('SEVO')        % sevoflurane (agent-specific gas analyser)
        DES     ('DES')         % desflurane (agent-specific gas analyser)
        GAS2    ('GAS2')        % total volatile agent (agent-generic analyser)
    end

    properties (SetAccess = immutable)
        str
    end

    methods
        function obj = TrackName(str)
            obj.str = str;
        end

        function s = char(obj)
            s = obj.str;
        end
    end
end
