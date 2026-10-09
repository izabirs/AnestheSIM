classdef TrackSource
    %TRACKSOURCE Devices and monitors that can produce a canonical signal.

    enumeration
        BIS       ('BIS')        % BIS monitor
        ORCHESTRA ('Orchestra')  % Fresenius Kabi Orchestra infusion pumps
        EV1000    ('EV1000')     % Edwards EV1000 haemodynamic monitor
        SOLAR8000 ('Solar8000')  % GE Solar 8000 patient monitor
        PRIMUS    ('Primus')     % Draeger Primus anaesthesia workstation
    end

    properties (SetAccess = immutable)
        str
    end

    methods
        function obj = TrackSource(str)
            obj.str = str;
        end

        function s = char(obj)
            s = obj.str;
        end
    end
end
