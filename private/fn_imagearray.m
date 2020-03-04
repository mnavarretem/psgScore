% Function: fn_imagearray
% 
% Description:
% This function makes the image of the data contained in an Array. 
% 
% f_ImageArray(Z)
% f_ImageArray(Z,X,Y)
% f_ImageArray(...,'PropertyName',propertyvalue)
% h = f_ImageArray(...)
% [him,hco] = f_ImageArray(...)
%
% Input Parameters:
% 
% Z(*): Array to display as image
% X: Vector containing the x axis 
% Y: Vector containing the y axis 
%
% Output Parameters:
%
% him: Handle of the image
% hco: Handle of the colorbar if displayed
%
% Properties:
% This section provides a description of properties. Curly braces { } enclose default values.
%
% Parent
%   axes handle
%   Image parent. The handle of the axes' parent object.
% NewFigure
%   true | {false}
%   Set to TRUE to force the creation of a new figure
% Invert
%   true | {false}
%   Set to TRUE to invert upside down the resulting image
% Method
%   {'image'} | 'contour'
%   Method to display 2-D Array
% Limits
%	[LimMin, LimMax]
% 	Two-element vector that limits the range of data values in the Array 
% Colormap
%   String Name of the desired colormap | m-by-3 matrix of RGB values
%   String containing the name of the desired colormap or an array of red, green, and blue (RGB) 
%   intensity values that define m individual colors. (see "help colormap")
% ColorLevels
%   Number of color levels
% 	Number of levels inside the colormap. If Colormap is a matrix, then this value is ignored
% ContourSteps
%   Number of color steps
%   When display method is contour, this property set the number of contour lines in the
%   figure.
% ColorBar
%   true | {false}
%   Set to TRUE to display the colorbar
% ColorBarLocation
%   'up'|'down'|'left'|{'right'}
%   Position of the colorbar according to the axes
% ColorBarTicks
%   Vector with Colobar ticks
%   Vector with colorbar ticks inside Limits
% Stretch
%   true | {false}
%   Set to TRUE to mantain de position values of the axes when colorbar is displayed
%
% (*) Required parameters
% 
function varargout = fn_imagearray(varargin)

if nargin < 1
    error('[f_ImageArray] - ERROR: Bad number of parameters')    
end

v_ArgParam	= varargin;

for kk = 1:nargin
    switch kk
        case 1            
            m_Array	= varargin{kk};
            v_XAxis	= 1:size(m_Array,2);
            v_YAxis	= 1:size(m_Array,1);
            
            v_ArgParam  = v_ArgParam(2:end);
        case 2
            if isnumeric(varargin{kk});                
                v_XAxis	= varargin{kk};
            
            v_ArgParam  = v_ArgParam(2:end);
            end
        case 3
            if isnumeric(varargin{kk}) && isnumeric(varargin{kk-1});                
                v_YAxis	= varargin{kk};
            
                v_ArgParam  = v_ArgParam(2:end);
            end            
        otherwise
    end
end

st_In           = inputParser;
s_hAxes         = [];
v_Limits        = [];
str_ColorM      = 'hot';
s_ColorLev      = 256;
s_NewFigure     = false;
s_Invert        = false;
v_ExpectIm      = {'surface','image','contour'};
str_Image       = 'image';
s_ContStep      = 10;
v_CbarTicks     = [];
s_IsColBar      = false;
v_ExpBarPos     = {'up','down','left','right'};
str_ColBarLoc	= 'right';
s_IsStretch     = true;
s_IsNonEquAxis	= false;

addRequired(st_In,'m_Array',@isnumeric);
addRequired(st_In,'v_XAxis',@isnumeric);
addRequired(st_In,'v_YAxis',@isnumeric);
addParameter(st_In,'Parent',s_hAxes,@ishandle);
addParameter(st_In,'NewFigure',s_NewFigure);
addParameter(st_In,'Invert',s_Invert);
addParameter(st_In,'Method',str_Image,@(x) any(validatestring(x,v_ExpectIm)));
addParameter(st_In,'Limits',v_Limits,@isnumeric);
addParameter(st_In,'Colormap',str_ColorM);
addParameter(st_In,'ColorLevels',s_ColorLev,@isnumeric);
addParameter(st_In,'ContourSteps',s_ContStep,@isnumeric);
addParameter(st_In,'ColorBar',s_IsColBar);
addParameter(st_In,'ColorBarTicks',v_CbarTicks);
addParameter(st_In,'ColorBarLocation',str_ColBarLoc,@(x) any(validatestring(x,v_ExpBarPos)));
addParameter(st_In,'Stretch',s_IsStretch);
addParameter(st_In,'NonEqualAxis',s_IsNonEquAxis);

parse(st_In,m_Array,v_XAxis,v_YAxis,v_ArgParam{:})

m_Array         = st_In.Results.m_Array;
v_XAxis         = st_In.Results.v_XAxis;
v_YAxis         = st_In.Results.v_YAxis;
s_hAxes         = st_In.Results.Parent;
s_NewFigure     = st_In.Results.NewFigure;
s_Invert        = st_In.Results.Invert;
str_Image       = st_In.Results.Method;
v_Limits        = st_In.Results.Limits;
str_ColorM      = st_In.Results.Colormap;
s_ColorLev      = st_In.Results.ColorLevels;
s_ContStep      = st_In.Results.ContourSteps;
s_IsColBar      = st_In.Results.ColorBar;
str_ColBarLoc	= st_In.Results.ColorBarLocation;
v_CbarTicks     = st_In.Results.ColorBarTicks;
s_IsStretch     = st_In.Results.Stretch;
s_IsNonEquAxis	= st_In.Results.NonEqualAxis;

clear st_In
if ~isreal(m_Array)
    m_Array = abs(m_Array);
end

if isempty(v_Limits)
    v_Limits    = [min(m_Array(:)),max(m_Array(:))];
end

if s_NewFigure
    figure
end

if isempty(s_hAxes)
    s_hAxes	= gca;
end


if ~s_IsNonEquAxis && ...
        (numel(v_XAxis) ~= size(m_Array,2) || numel(v_YAxis) ~= size(m_Array,1))
    error('[f_ImageArray] - ERROR: Axis vectors do not match input array')  
end

if ischar(str_ColorM)
    eval(sprintf('colormap(%s(%d))', str_ColorM, s_ColorLev));
else
    colormap(str_ColorM);
end
    
switch lower(str_Image)
    case 'surface'      % TO KEEP WORKING ON IT
        set(s_hAxes,'Clim',v_Limits)
        m_Colormap  = colormap(gca);
        s_ColorN    = size(m_Colormap,1);

        s_m	= (s_ColorN - 1)/(v_Limits(2)-v_Limits(1));
        s_b	= 1 - v_Limits(1)*s_m;

        m_ColorId	= round(m_Array * s_m + s_b);
        
        v_Handles(1)	= surf(v_XAxis, v_YAxis, m_Array, 'CData', m_ColorId,...
                        'Parent',s_hAxes,'CDataMapping','direct');
        shading(gca, 'flat');
        
        v_CamPos    = get(s_hAxes,'CameraPosition');
        v_CamPos    = [mean(v_XAxis),mean(v_YAxis),v_CamPos(3)];
                        
        set(s_hAxes,'CameraUpVector',[0 1 0],'CameraPosition',v_CamPos)
        set(s_hAxes,'Xlim',[min(v_XAxis),max(v_XAxis)])
        set(s_hAxes,'Ylim',[min(v_YAxis),max(v_YAxis)])
        set(s_hAxes,'Zlim',v_Limits)
        
    case 'image'    
        
        if s_IsNonEquAxis
            v_XAxis     = v_XAxis(:);
            v_XAxisAux  = zeros(numel(v_XAxis) + 1, 1);
            v_XAxisAux(2:end - 1)	= diff(v_XAxis) / 2;
            v_XAxisAux(1)   = v_XAxisAux(2);
            v_XAxisAux(end) = v_XAxisAux(end - 1);
            v_XAxisAux(1:end - 1)	= v_XAxis - v_XAxisAux(1:end - 1);
            v_XAxisAux(end) = v_XAxis(end) + v_XAxisAux(end);
            
            s_Min       = min(v_XAxisAux);
            s_Max       = max(v_XAxisAux);
            s_Dis       = s_Max - s_Min;
            v_XAxisAux  = (v_XAxisAux - s_Min)./ s_Dis;
            
            s_Min       = min(v_XAxis);
            s_Max       = max(v_XAxis);
            s_Dis       = s_Max - s_Min;
            v_XAxisAux  = v_XAxisAux.* s_Dis;
            v_XAxisAux  = v_XAxisAux + s_Min;
            
            v_YAxis = v_YAxis(:);
            v_YAxisAux = zeros(numel(v_YAxis) + 1, 1);
            v_YAxisAux(2:end - 1) = diff(v_YAxis) / 2;
            v_YAxisAux(1) = v_YAxisAux(2);
            v_YAxisAux(end) = v_YAxisAux(end - 1);
            v_YAxisAux(1:end - 1) = v_YAxis - v_YAxisAux(1:end - 1);
            v_YAxisAux(end) = v_YAxis(end) + v_YAxisAux(end);
            
            s_Min = min(v_YAxisAux);
            s_Max = max(v_YAxisAux);
            s_Dis = s_Max - s_Min;
            v_YAxisAux = (v_YAxisAux - s_Min)./ s_Dis;
            
            s_Min = min(v_YAxis);
            s_Max = max(v_YAxis);
            s_Dis = s_Max - s_Min;
            v_YAxisAux = v_YAxisAux.* s_Dis;
            v_YAxisAux = v_YAxisAux + s_Min;
            
            m_DataAux = zeros(size(m_Array, 1) + 1, size(m_Array, 2) + 1);
            m_DataAux(1:end - 1, 1:end - 1) = m_Array;
            m_DataAux(end, :) = min(m_Array(:));
            m_DataAux(:, end) = min(m_Array(:));
            
            v_Handles(1)	= pcolor(s_hAxes,v_XAxisAux, v_YAxisAux, m_DataAux);
            shading(s_hAxes, 'flat');
        
            if s_Invert
                set(s_hAxes, 'YDir', 'reverse');
            end

            if ~isempty(v_Limits)
                set(s_hAxes, 'CLim', v_Limits);
            end
        else
            v_Handles(1)	= imagesc(v_XAxis, v_YAxis, m_Array,'Parent',s_hAxes,v_Limits);
            axis(s_hAxes,'xy')
        end
        
    case 'contour'
        v_Limits        = linspace(v_Limits(1),v_Limits(2),s_ContStep);
        
        if min(m_Array(:)) > v_Limits(1)
            [~,s_Idx]       = min(m_Array(:));
            m_Array(s_Idx)  = v_Limits(1);
        end
        
        if max(m_Array(:)) < v_Limits(end)
            [~,s_Idx]       = max(m_Array(:));
            m_Array(s_Idx)  = v_Limits(end);            
        end
        
        [~,v_Handles(1)]= contourf(s_hAxes,v_XAxis, v_YAxis, m_Array, v_Limits);        
end

if s_IsColBar
    str_cUnits	= get(s_hAxes,'Units');
    
    set(s_hAxes,'Units','normalized'); 
    
    v_AxePos    = get(s_hAxes,'Position');
    
    switch str_ColBarLoc
        case 'up'
            str_ColBarLoc	= 'NorthOutside';
            s_VerticalBar   = 0;
        case 'down'
            str_ColBarLoc	= 'SouthOutside';
            s_VerticalBar   = 0;
        case 'left'
            str_ColBarLoc	= 'WestOutside';
            s_VerticalBar   = 1;
        case 'right'
            str_ColBarLoc	= 'EastOutside';
            s_VerticalBar   = 1;
    end    
    
    if ~isempty(v_CbarTicks)        
        v_CbarTicks	= v_CbarTicks(v_CbarTicks >= v_Limits(1) & ...
                    v_CbarTicks <= v_Limits(end));
    end
    
    if isempty(v_CbarTicks)
        v_CbarTicks	= linspace(v_Limits(1),v_Limits(end),s_ContStep);
    end
    
%     if any(diff(v_CbarTicks))
%         v_CbarTicks	= linspace(v_Limits(1),v_Limits(end),5);
%     end
    
    if s_VerticalBar
        v_Handles(2)    = colorbar(......
                        'Peer',s_hAxes,...
                        'Location',str_ColBarLoc,...
                        'YTick',v_CbarTicks);
                    
    else
        v_Handles(2)    = colorbar(...
                        'Peer',s_hAxes,...
                        'Location',str_ColBarLoc,...
                        'XTick',v_CbarTicks);
    end
    
    set(v_Handles(2),'Fontsize',get(s_hAxes,'Fontsize'))

    if s_IsStretch
        set(s_hAxes,'Position',v_AxePos)
    end   
    
    v_cPosition     = get(v_Handles(2),'Position');
    
    switch str_ColBarLoc
        case 'NorthOutside'
            v_cPosition(2)	= v_AxePos(2) + v_AxePos(4) + 0.2*v_cPosition(4);
        case 'SouthOutside'
            v_cPosition(2)	= v_AxePos(2)  - 0.1*v_cPosition(4);
        case 'WestOutside'
            v_cPosition(1)	= v_AxePos(1) - 0.1*v_cPosition(3);
        case 'EastOutside'
            v_cPosition(1)	= v_AxePos(1) + v_AxePos(3) + 0.3*v_cPosition(3);
    end    
    
    v_cPosition(3)  = 0.4*v_cPosition(3);
    set(v_Handles(2),'Position',v_cPosition) 
    set(v_Handles(2),'Units',str_cUnits) 
    
end

% varargout = cell(1,nargout);
% for kk = 1:nargout
%     varargout{kk} = v_Handles(kk);
% end

if s_Invert
    set(s_hAxes,'yDir','reverse')
end

varargout = cell(1,nargout);
for kk = 1:numel(v_Handles)
    varargout{kk} = v_Handles(kk);
end
