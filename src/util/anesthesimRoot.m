function root = anesthesimRoot()
%ANESTHESIMROOT Absolute path of the AnestheSIM installation folder.
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
