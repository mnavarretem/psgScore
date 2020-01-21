% % Function: fn_arrayimage
% 
% Description:
% This function makes the image of the data contained in an Array. 
% 
% fn_arrayimage(mx_array)
% fn_arrayimage(mx_array,st_cfg)
% h = fn_arrayimage(...)
%
% Input Parameters:
% 
% mx_array(*):  Array to display as image
% st_cfg :      Config structure
%
% Output Parameters:
%
% him: Handle of the image
% hco: Handle of the colorbar if displayed
%
% Config structure:
% This section provides a description of the Config structure. 
% Curly braces { } enclose default values.
%
% xAxis 
%   Vector containing the x axis 
% yAxis
% 	Vector containing the y axis 
% limits
%	[LimMin, LimMax]
% 	Two-element vector that limits the range of data values in the Array 
% parent
%   axes handle
%   Image parent. The handle of the axes' parent object.
% colormap
%   String Name of the desired colormap | m-by-3 matrix of RGB values
%   String containing the name of the desired colormap or an array of red, green, and blue (RGB) 
%   intensity values that define m individual colors. (see "help colormap")
% levels
%   Number of color levels
% 	Number of levels inside the colormap. If Colormap is a matrix, then this value is ignored
% numContour
%   Number of color steps
%   When display method is contour, this property set the number of contour lines in the
%   figure.
% colorbar
%   true | {false}
%   Set to TRUE to display the colorbar
% cbarticks
%   Vector with Colobar ticks
%   Vector with colorbar ticks inside Limits
% cbarpos
%   'up'|'down'|'left'|{'right'}
%   Position of the colorbar according to the axes
% invert
%   true | {false}
%   Set to TRUE to invert upside down the resulting image
% imageMethod
%   {'image'} | 'contour'
%   Method to display 2-D Array
% newFigure
%   true | {false}
%   Set to TRUE to force the creation of a new figure
% cbarstretch
%   true | {false}
%   Set to TRUE to mantain de position values of the axes when colorbar is displayed
% nonLinear
%   true | {false}
%   Set to TRUE when yAxis has non linear scale
%
% (*) Required parameters
% 
function varargout = fn_arrayimage(mx_array,st_cfg)

%% Define input variables
if nargin < 1
    error('[fn_arrayimage] - ERROR: Bad number of parameters')    
end
if nargin < 2
    st_cfg = struct; 
end

if ~isfield(st_cfg,'xAxis')
    st_cfg.xAxis        = 1:size(mx_array,2); 
end
if ~isfield(st_cfg,'yAxis')
    st_cfg.yAxis        = 1:size(mx_array,1); 
end
if ~isfield(st_cfg,'limits')
    st_cfg.limits       = []; 
end
if ~isfield(st_cfg,'parent')
    st_cfg.parent       = gca; 
end
if ~isfield(st_cfg,'colormap')
    st_cfg.colormap     = 'hot'; 
end
if ~isfield(st_cfg,'levels')
    st_cfg.levels       = 128; 
end
if ~isfield(st_cfg,'numContour')
    st_cfg.numContour	= 10; 
end
if ~isfield(st_cfg,'colorbar')
    st_cfg.colorbar     = false; 
end
if ~isfield(st_cfg,'cbarticks')
    st_cfg.cbarticks= []; 
end
if ~isfield(st_cfg,'cbarpos')
    st_cfg.cbarpos 	= 'right';
end
if ~isfield(st_cfg,'invert')
    st_cfg.invert       = false; 
end
if ~isfield(st_cfg,'imageMethod')
    st_cfg.imageMethod	= 'image'; 
end
if ~isfield(st_cfg,'newFigure')
    st_cfg.newFigure    = false; 
end
if ~isfield(st_cfg,'cbarstretch')
    st_cfg.cbarstretch      = false; 
end
if ~isfield(st_cfg,'nonLinear')
    st_cfg.nonLinear    = false; 
end

if ~isreal(mx_array)
    mx_array = abs(mx_array);
end

if ~isnumeric(mx_array)
    mx_array = single(mx_array);
end

if isempty(st_cfg.limits)
    st_cfg.limits	= [min(mx_array(:)),max(mx_array(:))];
end

if st_cfg.newFigure
    figure
end

if ~st_cfg.nonLinear && ...
	(numel(st_cfg.xAxis) ~= size(mx_array,2) || numel(st_cfg.yAxis) ~= size(mx_array,1))
    error('[fn_arrayimage] - ERROR: Axis vectors do not match input array')  
end

if ischar(st_cfg.colormap)
    eval(sprintf('colormap(%s(%d))', st_cfg.colormap, st_cfg.levels));
else
    colormap(st_cfg.colormap);
end
    
%% Plot image

if diff(st_cfg.limits) == 0
    st_cfg.limits	= [st_cfg.limits(1)-1,st_cfg.limits(1)+1];
end

switch lower(st_cfg.imageMethod)
    case 'surface'      % TO KEEP WORKING ON IT
        set(st_cfg.parent,'Clim',st_cfg.limits)
        mx_colormap	= colormap(gca);
        nm_colorNum	= size(mx_colormap,1);

        nm_m	= (nm_colorNum - 1)/(st_cfg.limits(2)-st_cfg.limits(1));
        nm_b	= 1 - st_cfg.limits(1)*nm_m;

        m_colorId	= round(mx_array * nm_m + nm_b);
        
        ob_hAxis(1)	= surf(st_cfg.xAxis, st_cfg.yAxis, mx_array, ...
                    'CData', m_colorId,...
                    'Parent',st_cfg.parent,'CDataMapping','direct');
        
        shading(gca, 'flat');
        
        vt_camPos    = get(st_cfg.parent,'CameraPosition');
        vt_camPos    = [mean(st_cfg.xAxis),mean(st_cfg.yAxis),vt_camPos(3)];
                        
        set(st_cfg.parent,'CameraUpVector',[0 1 0],'CameraPosition',vt_camPos)
        set(st_cfg.parent,'Xlim',[min(st_cfg.xAxis),max(st_cfg.xAxis)])
        set(st_cfg.parent,'Ylim',[min(st_cfg.yAxis),max(st_cfg.yAxis)])
        set(st_cfg.parent,'Zlim',st_cfg.limits)
        
    case 'image'    
        
        if st_cfg.nonLinear
            st_cfg.xAxis     = st_cfg.xAxis(:);
            st_cfg.xAxisAux  = zeros(numel(st_cfg.xAxis) + 1, 1);
            st_cfg.xAxisAux(2:end - 1)	= diff(st_cfg.xAxis) / 2;
            st_cfg.xAxisAux(1)   = st_cfg.xAxisAux(2);
            st_cfg.xAxisAux(end) = st_cfg.xAxisAux(end - 1);
            st_cfg.xAxisAux(1:end - 1)	= st_cfg.xAxis - st_cfg.xAxisAux(1:end - 1);
            st_cfg.xAxisAux(end) = st_cfg.xAxis(end) + st_cfg.xAxisAux(end);
            
            nm_min          = min(st_cfg.xAxisAux);
            nm_max          = max(st_cfg.xAxisAux);
            nm_range        = nm_max - nm_min;
            st_cfg.xAxisAux	= (st_cfg.xAxisAux - nm_min)./ nm_range;
            
            nm_min          = min(st_cfg.xAxis);
            nm_max          = max(st_cfg.xAxis);
            nm_range        = nm_max - nm_min;
            st_cfg.xAxisAux	= st_cfg.xAxisAux.* nm_range;
            st_cfg.xAxisAux	= st_cfg.xAxisAux + nm_min;
            
            st_cfg.yAxis                = st_cfg.yAxis(:);
            st_cfg.yAxisAux             = zeros(numel(st_cfg.yAxis) + 1, 1);
            st_cfg.yAxisAux(2:end - 1)  = diff(st_cfg.yAxis) / 2;
            st_cfg.yAxisAux(1)          = st_cfg.yAxisAux(2);
            st_cfg.yAxisAux(end)        = st_cfg.yAxisAux(end - 1);
            st_cfg.yAxisAux(1:end - 1)  = st_cfg.yAxis - ...
                                        st_cfg.yAxisAux(1:end - 1);
            st_cfg.yAxisAux(end)        = st_cfg.yAxis(end) + ...
                                        st_cfg.yAxisAux(end);
            
            nm_min          = min(st_cfg.yAxisAux);
            nm_max          = max(st_cfg.yAxisAux);
            nm_range        = nm_max - nm_min;
            st_cfg.yAxisAux = (st_cfg.yAxisAux - nm_min)./ nm_range;
            
            nm_min          = min(st_cfg.yAxis);
            nm_max          = max(st_cfg.yAxis);
            nm_range        = nm_max - nm_min;
            st_cfg.yAxisAux = st_cfg.yAxisAux.* nm_range;
            st_cfg.yAxisAux = st_cfg.yAxisAux + nm_min;
            
            m_DataAux                       = zeros(size(mx_array, 1) + 1, ...
                                            size(mx_array, 2) + 1);
            m_DataAux(1:end - 1, 1:end - 1) = mx_array;
            m_DataAux(end, :)               = min(mx_array(:));
            m_DataAux(:, end)               = min(mx_array(:));
            
            ob_hAxis(1)	= pcolor(st_cfg.parent,st_cfg.xAxisAux,...
                        st_cfg.yAxisAux, m_DataAux);
            shading(st_cfg.parent, 'flat');
        
            if st_cfg.invert
                set(st_cfg.parent, 'YDir', 'reverse');
            end

            if ~isempty(st_cfg.limits)
                set(st_cfg.parent, 'CLim', st_cfg.limits);
            end
        else
            ob_hAxis(1)	= imagesc(st_cfg.xAxis, st_cfg.yAxis, mx_array,...
                        'Parent',st_cfg.parent,st_cfg.limits);
            axis(st_cfg.parent,'xy')
        end
        
    case 'contour'
        st_cfg.limits	= linspace(st_cfg.limits(1),st_cfg.limits(2),...
                        st_cfg.numContour);
        
        if min(mx_array(:)) > st_cfg.limits(1)
            [~,nm_Idx]          = min(mx_array(:));
            mx_array(nm_Idx)    = st_cfg.limits(1);
        end
        
        if max(mx_array(:)) < st_cfg.limits(end)
            [~,nm_Idx]          = max(mx_array(:));
            mx_array(nm_Idx)    = st_cfg.limits(end);            
        end
        
        [~,ob_hAxis(1)]	= contourf(st_cfg.parent,st_cfg.xAxis, st_cfg.yAxis, ...
                        mx_array, st_cfg.limits);        
end

if st_cfg.colorbar
    vt_axePos	= get(st_cfg.parent,'Position');
    switch st_cfg.cbarpos
        case 'up'
            st_cfg.cbarpos	= 'NorthOutside';
            nm_verticalBar   = 0;
        case 'down'
            st_cfg.cbarpos	= 'SouthOutside';
            nm_verticalBar   = 0;
        case 'left'
            st_cfg.cbarpos	= 'WestOutside';
            nm_verticalBar   = 1;
        case 'right'
            st_cfg.cbarpos	= 'EastOutside';
            nm_verticalBar   = 1;
    end    
    
    if ~isempty(st_cfg.cbarticks)        
        st_cfg.cbarticks	= st_cfg.cbarticks(...
                                st_cfg.cbarticks >= st_cfg.limits(1) & ...
                                st_cfg.cbarticks <= st_cfg.limits(end));
    end
    
    if isempty(st_cfg.cbarticks)
        st_cfg.cbarticks	= linspace(st_cfg.limits(1),st_cfg.limits(end),...
                                st_cfg.numContour);
    end
        
    if nm_verticalBar
        ob_hAxis(2)    = colorbar(......
                        'Peer',st_cfg.parent,...
                        'Location',st_cfg.cbarpos,...
                        'YTick',st_cfg.cbarticks);
                    
    else
        ob_hAxis(2)    = colorbar(...
                        'Peer',st_cfg.parent,...
                        'Location',st_cfg.cbarpos,...
                        'XTick',st_cfg.cbarticks);
    end
    
    set(ob_hAxis(2),'Fontsize',get(st_cfg.parent,'Fontsize'))

    if st_cfg.cbarstretch
        set(st_cfg.parent,'Position',vt_axePos)
    end   
    
    vt_cPosition     = get(ob_hAxis(2),'Position');
    
    switch st_cfg.cbarpos
        case 'NorthOutside'
            vt_cPosition(2)	= vt_axePos(2) + vt_axePos(4) + 0.2*vt_cPosition(4);
        case 'SouthOutside'
            vt_cPosition(2)	= vt_axePos(2) - 0.1*vt_cPosition(4);
        case 'WestOutside'
            vt_cPosition(1)	= vt_axePos(1) - 0.1*vt_cPosition(3);
        case 'EastOutside'
            vt_cPosition(1)	= vt_axePos(1) + vt_axePos(3) + 0.3*vt_cPosition(3);
    end    
    
    vt_cPosition(3)  = 0.4*vt_cPosition(3);
    set(ob_hAxis(2),'Position',vt_cPosition)
end

if st_cfg.invert
    set(st_cfg.parent,'yDir','reverse')
end

varargout = cell(1,nargout);
for kk = 1:numel(ob_hAxis)
    varargout{kk} = ob_hAxis(kk);
end
