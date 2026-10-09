classdef VitalSignal
    %VITALSIGNAL A canonical signal (TrackName) produced by a device (TrackSource).
    %   VitalSignal is the database boundary: it expands a canonical request
    %   into the channel strings a repository exposes, e.g.
    %
    %       VitalSignal(TrackName.PROP20, TrackSource.ORCHESTRA).Channels
    %       -> {'Orchestra/PPF20_RATE', 'Orchestra/PPF20_CE', 'Orchestra/PPF20_CP'}
    %
    %   Supporting a differently named source means adding a case to
    %   channelStrings; no model code changes.

    properties (SetAccess = immutable)
        Name   (1,1) TrackName   = TrackName.BIS
        Source (1,1) TrackSource = TrackSource.BIS
    end

    properties (Dependent)
        Channels   % cell array of repository channel strings
    end

    methods
        function obj = VitalSignal(name, source)
            if nargin > 0
                obj.Name = name;
                obj.Source = source;
            end
        end

        function c = get.Channels(obj)
            c = VitalSignal.channelStrings(obj.Name, obj.Source);
        end

        function c = allChannels(objs)
            %ALLCHANNELS Concatenated channel strings of an array of signals.
            c = {};
            for k = 1:numel(objs)
                c = [c, objs(k).Channels]; %#ok<AGROW>
            end
        end

        function tf = has(objs, name)
            %HAS True if the signal array requests the canonical NAME.
            tf = any(arrayfun(@(s) s.Name == name, objs));
        end
    end

    methods (Static)
        function c = channelStrings(name, source)
            src = char(source);
            switch name
                case {TrackName.PROP20, TrackName.REMI20, TrackName.REMI50}
                    base = [src '/' char(name)];
                    c = {[base '_RATE'], [base '_CE'], [base '_CP']};
                case {TrackName.SEVO, TrackName.DES}
                    c = {[src '/INSP_' char(name)], [src '/EXP_' char(name)]};
                case TrackName.GAS2
                    c = {[src '/GAS2_INSPIRED'], [src '/GAS2_EXPIRED']};
                otherwise
                    c = {[src '/' char(name)]};
            end
        end
    end
end
