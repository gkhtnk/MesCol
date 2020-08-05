% MesCol
% handle class provide communication for CS-1000 (KONICA MINOLTA)

classdef MesCol < handle
  
  properties
    Port = 'COM1';
    BaudRate {mustBeMember(BaudRate, {4800,9600,19200})} = 9600;
    Terminator = 'LF';
    
    err = 'OK';
    serObj = [];
  end
  
  properties (Constant)
    DataBits = 8;
    StopBits = 1;
    Parity = 'none';
  end
  
  methods
    function obj = MesCol(varargin)
      % Constrct MesCol object
      % You can specify the Port and BaudRate
      % mesCol = MesCol();
      % mesCol = MesCol('COM1');
      % mesCol = MesCol('COM1', 9600);
      if 0 < nargin
        obj.Port = varargin{1};
      end
      if 1 < nargin
        obj.BaudRate = varargin{2};
      end
      obj.serObj = serial(obj.Port, 'Timeout', 1, ...
        'DataBits', obj.DataBits, ...
        'StopBits', obj.StopBits, ...
        'Parity', obj.Parity, ...
        'BaudRate', obj.BaudRate);
      
      % Give false to the 3rd argment not to open SerObj in the constructor
      % mesCol = MesCol('COM1', 9600, false);
      if nargin < 3 || varargin{3}
        obj.sopen();
      end
    end
    
    function SetRemoteOn(obj)
      % Set remote on
      % Read <RMT> for more detail
      fprintf(obj.serObj, 'RMT,1');
      obj.CheckReply();
    end
    
    function SetRemoteOff(obj)
      % Set remote off
      % Read <RMT> for more detail
      fprintf(obj.serObj, 'RMT,0');
      obj.CheckReply();
    end
    
    function StartMes(obj)
      % Start measurement
      % Read <MES> for more detail
      fprintf(obj.serObj, 'MES,1');
      pause(10);
      [~, data] = obj.CheckReply();
      intTime = str2double(data{1});
      pause(intTime*2 + 10);
      obj.CheckReply();
      
    end
    
    function StopMes(obj)
      % Stop measurement
      % Read <MES> for more detail
      fprintf(obj.serObj, 'MES,0');
      pause(2);
      [~, data] = obj.CheckReply();
      intTime = str2double(data{1});
      fprintf('# MES         : %d sec', intTime);
      pause(10+intTime);
      obj.CheckReply();
    end
    
    function SetMesMode(obj, mode, time)
      % Set measurement mode
      % Read <MMS> for more detail
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
    
    function data = GetMesStatus(obj)
      % Get measurement status
      % Read <STR> for more detail
      fprintf(obj.serObj, 'STR');
      [~, data] = obj.CheckReply();
    end
    
    function [data, info] = GetColSpec(obj, fov)
      % Get measuared color spectral data
      % fov : 0 for 2 degree (default), 1 for 10 degree
      % Read <BDR> for more detail
      % lambda 380:1:780 nm
      if exist('fov', 'var') && fov
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
    
    function [data, info] = GetColProp(obj, fov)
      % Get measuared color properties data
      % fov : 0 for 2 degree (default), 1 for 10 degree
      % Read <BDR> for more detail
      % Le, Lv, X, Y, Z, x, y, u', v', T, duv
      if exist('fov', 'var') && fov
        fov = 1;
      else
        fov = 0;
      end
      fprintf(obj.serObj, sprintf('BDR,1,%d,0', fov));
      [~, info] = obj.CheckReply();
      fprintf(obj.serObj, '&');
      data = cellfun(@str2double, regexp(fgetl(obj.serObj), ',', 'split'), 'UniformOutput', false);
    end
  end
  
  methods (Hidden)
    function delete(obj)
      if strcmp(obj.serObj.Status, 'open')
        obj.sclose();
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
      error(sprintf('MESCOL:%s', status), 'Error in MesCol CODE %s, Read the manual document for more detail.\n', status);
    end
    
    function [status, data] = CheckReply(obj)
      str = regexp(fgetl(obj.serObj), ',', 'split');
      status = str{1};
      if ~strcmp(status, 'OK')
        obj.errFunc(status);
      end
      if 1 < length(str)
        data = str(2:end);
      else
        data = {};
      end
    end
  end
end
