% MesCol
% handle class provide communication for CS-1000 (KONICA MINOLTA)

classdef MesCol < handle
    
    properties
        Port = 'COM1';
        BaudRate = 9600;
        Terminator = 'LF';
        DataBits = 8;
        StopBits = 1;
        Parity = 'none';
        
        err = 'OK';
        
        serObj = [];
    end
    
    methods
        function obj = MesCol(varargin)
            if 0 < nargin
                obj.Port = varargin{1};
            end
            if 1 < nargin
                obj.BaudRate = varargin{2};
            end
            obj.serObj = serial(obj.Port, 'Timeout', 1, ...
                'DataBits', 8, ...
                'StopBits', 1, ...
                'Parity', 'none', ...
                'BaudRate', obj.BaudRate);
            fopen(obj.serObj);
        end
        
        function delete(obj)
            if strcmp(obj.serObj.Status, 'open')
                fclose(obj.serObj);
            end
            delete(obj.serObj);
        end
        
        function sopen(obj)
            fopen(obj.serObj);
        end
        
        function sclose(obj)
            fclose(obj.serObj);
        end
        
        function errFunc(obj, status)
            obj.err = status;
            obj.delete();
            error(sprintf('MESCOL:%s', status), 'Error in MesCol, CODE %s\n', status);
        end
        
        function [status, data] = CheckReply(obj)
            str = strsplit(fgetl(obj.serObj), ',');
            status = str{1};
            if ~strcmp(status, 'OK')
                obj.errFunc(status);
            end
            data = {};
            if 1 < length(str)
                data = str(2:end);
            end
        end
        
        % Set remote on/off
        function SetRemoteOn(obj)
            fprintf(obj.serObj, 'RMT,1');
            obj.CheckReply();
        end
        function SetRemoteOff(obj)
            fprintf(obj.serObj, 'RMT,0');
            obj.CheckReply();
        end
        
        % Start/Stop measurement
        function StartMes(obj)
            fprintf(obj.serObj, 'MES,1');
            pause(10);
            [~, data] = obj.CheckReply();
            intTime = str2double(data{1});
            pause(intTime*2 + 10);
            obj.CheckReply();

        end
        function StopMes(obj)
            fprintf(obj.serObj, 'MES,0');
            pause(2);
            [~, data] = obj.CheckReply();
            intTime = str2double(data{1});
            fprintf('# MES         : %d sec', intTime);
            pause(10+intTime);
            obj.CheckReply();
        end
        
        % Set measurement mode
        function SetMesMode(obj, mode, time)
            switch (mode)
                case {0, 2}
                    fprintf(obj.serObj, sprintf('MMS,%d,', mode));
                case {1}
                    fprintf(obj.serObj, sprintf('MMS,%d,%0.2f', mode, time));
                case {3}
                    fprintf(obj.serObj, sprintf('MMS,%d,%0.3f', mode, time));
            end
            obj.CheckReply();
        end
        
        % Get measurement status
        function data = GetMesStatus(obj)
            fprintf(obj.serObj, 'STR');
            [~, data] = obj.CheckReply();
        end
        
        % Get measuared color spectral data
        % lambda 380:1:780 nm
        function [data, info] = GetColSpec(obj, fov)
            if fov
                fov = 1;
            else
                fov = 0;
            end
            fprintf(obj.serObj, sprintf('BDR,0,%d,1', fov));
            [~, info] = obj.CheckReply();
            data = [];
            for li = 1:7
                fprintf(obj.serObj, '&');
                if li < 7
                    temp = fread(obj.serObj, 60, 'float32');
                else
                    temp = fread(obj.serObj, 41, 'float32');
                end
                data = [data; temp];
            end
        end
        
        % Get measuared color properties data
        % Le, Lv, X, Y, Z, x, y, u', v', T, duv
        function [data, info] = GetColProp(obj, fov)
            if fov
                fov = 1;
            else
                fov = 0;
            end
            fprintf(obj.serObj, sprintf('BDR,1,%d,0', fov));
            [~, info] = obj.CheckReply();
            fprintf(obj.serObj, '&');
            data = cellfun(@str2double, strsplit(fgetl(obj.serObj), ','), 'UniformOutput', false);
        end
    end
end
