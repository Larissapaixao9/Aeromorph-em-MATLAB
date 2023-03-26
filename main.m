function [] = AeroMorph_v506()
    clc,clear all,close all,format long
    camber_line=0;camber_line_0=0;camber_value=0;incidence_value=0;
    nodes=0;node_displacement=0;node_select=0;node_value=0; thickness_value=0;xc=0;
    xc_reset=0;yc=0;yc_reset=0;ga_progress=0;ga_total=0;


%Add all filepaths
    dir = cd;
    airfoildir = strcat(dir,'\airfoils');
    helpdir = strcat(dir,'\help');

%Load Airfoil
    inputfile=strcat(airfoildir,'\lrn1015.dat');
    [xc,yc]=textread(inputfile,'%f %f');
    nodes=[floor(length(xc)/2),floor(length(xc)*(36/80)),floor(length(xc)*(31/80)),floor(length(xc)*(24/80)),floor(length(xc)*(19/80)),floor(length(xc)*(15/80)),floor(length(xc)*(9/80)),1];
    xc_reset=xc;yc_reset=yc;
    [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
    camber_line_0=camber_line;
    thick=100*(max(yc)-min(yc));

%Build Figure
    set(0,'Units','pixels')
    sz = get(0,'ScreenSize');
    topfig=figure('Name','AeroMorph v.5.0','NumberTitle','off','Position',[(sz(3)-1024)/2 (sz(4)-640)/2 1024640],'MenuBar','None','Visible','off');
    set(topfig, 'color', [0 0 0]);%[.2 .4 1]
    frame1 = uipanel('Parent',topfig,'Position',[.025 .025 .95 .95],'BackgroundColor',[.85 0 0]);
    uicontrol('Parent',topfig,'Style','text','String',strcat([char(169),'2008-2009 Cody Lafountain, University of Cincinnati']),'Position',[2,0,350,15],'BackgroundColor','Black','ForegroundColor',[1 11],'HorizontalAlignment','Left','FontName','@Arial UnicodeMS','FontUnits','points','FontSize',8);

%Build Plot
    plot1 = axes('Parent',frame1,'Position',[.04,.05,.95,.5]);
    plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)

%Build Editor
    subframe2 = uipanel('Parent',frame1,'Title',['Editing Airfoil: ',inputfile],'Position',[.04 .56 .76 .43],'BackgroundColor',[1 1 1]);
    subframe3 = uipanel('Parent',frame1,'Title','Data','Position',[.80 .56 .19 .43],'BackgroundColor',[1 1 1]);

%Data Box
    uicontrol('Parent',subframe3,'Style','text','String','Node YValue','Position',[10,225,100,20],'BackgroundColor','White','HorizontalAlignment','Left','FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    node_value = uicontrol('Parent',subframe3,'Style','text','String',num2str(0),'Position',[10,205,100,20],'BackgroundColor','White','HorizontalAlignment','Left');

    uicontrol('Parent',subframe3,'Style','text','String','NodeDisplacement','Position',[10,185,130,20],'BackgroundColor','White','HorizontalAlignment','Left','FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    node_displacement = uicontrol('Parent',subframe3,'Style','text','String',num2str(0),'Position',[10,165,100,20],'BackgroundColor','White','HorizontalAlignment','Left');

    uicontrol('Parent',subframe3,'Style','text','String','Thickness%','Position',[10,145,100,20],'BackgroundColor','White','HorizontalAlignment','Left','FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    thickness_value = uicontrol('Parent',subframe3,'Style','text','String',num2str(thick),'Position',[10,125,100,20],'BackgroundColor','White','HorizontalAlignment','Left');

    uicontrol('Parent',subframe3,'Style','text','String','MaxCamber','Position',[10,105,100,20],'BackgroundColor','White','HorizontalAlignment','Left','FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    camber_value = uicontrol('Parent',subframe3,'Style','text','String',num2str(max_camber),'Position',[10,85,100,20],'BackgroundColor','White','HorizontalAlignment','Left');

    uicontrol('Parent',subframe3,'Style','text','String','SweepAngle','Position',[10,65,100,20],'BackgroundColor','White','HorizontalAlignment','Left','FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    sweep_value = uicontrol('Parent',subframe3,'Style','text','String','0','Position',[10,45,100,20],'BackgroundColor','White','HorizontalAlignment','Left');

    uicontrol('Parent',subframe3,'Style','text','String','IncidenceAngle','Position',[10,25,105,20],'BackgroundColor','White','HorizontalAlignment','Left','FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    incidence_value = uicontrol('Parent',subframe3,'Style','text','String',num2str(incidence_angle),'Position',[10,5,100,20],'BackgroundColor','White','HorizontalAlignment','Left');


 %Editor Box
    
 %Column 1
    uicontrol('Parent',subframe2,'Style','text','String','SelectNode','Position',[10,190,150,20],'BackgroundColor',[1 1 1],'FontName','@ArialUnicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    node_select = uicontrol('Parent',subframe2,'Style','popupmenu','String','1|2|3|4|5|6|7|8','Position',[10,170,150,20],'Callback',@getnode,'BackgroundColor','White');

    uicontrol('Parent',subframe2,'Style','text','String','Raise/LowerNode','Position',[10,150,150,20],'BackgroundColor',[1 1 1],'FontName','@ArialUnicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    node_edit = uicontrol('Parent',subframe2,'Style','popupmenu','String','0|+0.025|+0.01|+0.005|-0.005|-0.01|-0.025','Position',[10,130,150,20],'BackgroundColor','White','Callback',@setnode);

    uicontrol('Parent',subframe2,'Style','text','String','ThicknessChange','Position',[10,110,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    thickness_edit = uicontrol('Parent',subframe2,'Style','popupmenu','String','0|+4%|+2%|+1%|-1%|-2%|-4%','Position',[10,90,150,20],'BackgroundColor','White','Callback',@set_thickness);

    fit_line_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Smooth Surface','Position',[10,50,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@topcurvefit,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    reset_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Reset Airfoil','Position',[10,30,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@reset_airfoil,'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    exit_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Exit Editor','Position',[10,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@exit_editor,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

 %Column 2
    uicontrol('Parent',subframe2,'Style','text','String','Input_Filename','Position',[170,190,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    filename_load = uicontrol('Parent',subframe2,'Style','edit','String','lrn1015','Position',[170,170,150,20],'BackgroundColor','White');
    filename_load_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Load Airfoil','Position',[170,150,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@load_airfoil,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

    uicontrol('Parent',subframe2,'Style','text','String','Editor_Output','Position',[170,130,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    filename_edit = uicontrol('Parent',subframe2,'Style','edit','String','lrn1015-AM','Position',[170,110,150,20],'BackgroundColor','White');
    save_output_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Save Airfoil','Position',[170,90,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@saveoutput,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

    zoom_in_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Zoom on Leading','Position',[170,50,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@zoom_leading,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    zoom_out_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Zoom Out','Position',[170,30,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@zoom_out,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    help_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Open Help','Position',[170,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@open_help,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

 %Column 3
    uicontrol('Parent',subframe2,'Style','text','String','Sweep Angle ( °)','Position',[330,190,150,20],'BackgroundColor',[1 1 1],'FontName','@ArialUnicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    sweep_angle_box = uicontrol('Parent',subframe2,'Style','edit','String','0','Position',[330,170,150,20],'BackgroundColor','White');
    sweep_wing_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Sweep Wing','Position',[330,150,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@get_sweep_angle,'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');

    ga_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Optimize Shape','Position',[330,50,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@ga_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    interpolate_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Merge With...','Position',[330,30,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@int_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    generate_run_button = uicontrol('Parent',subframe2,'Style','pushbutton','String','Generate Run','Position',[330,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@run_select,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

%Run Figure

    run_fig = figure('Name','AeroMorph v.5.0|GenerateRun','NumberTitle','off','Position',[(sz(3)-374)/2 (sz(4)-320)/2 374320],'MenuBar','None','Visible','off');
    set(run_fig, 'color', [0 0 0]);%[.2 .4 1]
    run_frame1 = uipanel('Parent',run_fig,'Position',[.025 .025 .95 .95],'BackgroundColor',[.85 0 0]);
    run_frame2 = uipanel('Parent',run_frame1,'Position',[.025 .025 .95 .95],'BackgroundColor',[1 1 1]);
    
    re_check = uicontrol('Parent',run_frame2,'Style','togglebutton','String','Reynolds Number(s)','Position',[10,250,150,20],'BackgroundColor',[.8 .8 .8],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    re_start = uicontrol('Parent',run_frame2,'Style','edit','String','5e5','Position',[10,230,50,20],'BackgroundColor',[.95 .95 .95]);
    re_step = uicontrol('Parent',run_frame2,'Style','edit','String','1e5','Position',[60,230,50,20],'BackgroundColor','White');
    re_end = uicontrol('Parent',run_frame2,'Style','edit','String','5e5','Position',[110,230,50,20],'BackgroundColor','White');

    mach_check = uicontrol('Parent',run_frame2,'Style','togglebutton','String','Mach Number(s)','Position',[10,210,150,20],'BackgroundColor',[.8 .8 .8],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    mach_start = uicontrol('Parent',run_frame2,'Style','edit','String','0.2','Position',[10,190,50,20],'BackgroundColor',[.95 .95 .95]);
    mach_step = uicontrol('Parent',run_frame2,'Style','edit','String','0.05','Position',[60,190,50,20],'BackgroundColor','White');
    mach_end = uicontrol('Parent',run_frame2,'Style','edit','String','0.2','Position',[110,190,50,20],'BackgroundColor','White');

    alfa_check = uicontrol('Parent',run_frame2,'Style','togglebutton','String','Alpha(s) ( ° )','Position',[10,170,150,20],'BackgroundColor',[.8 .8 .8],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold','Value',1);
    alfa_start = uicontrol('Parent',run_frame2,'Style','edit','String','-2','Position',[10,150,50,20],'BackgroundColor',[.95 .95 .95]);
    alfa_step = uicontrol('Parent',run_frame2,'Style','edit','String','0.2','Position',[60,150,50,20],'BackgroundColor','White');
    alfa_end = uicontrol('Parent',run_frame2,'Style','edit','String','10','Position',[110,150,50,20],'BackgroundColor','White');

    t_check = uicontrol('Parent',run_frame2,'Style','togglebutton','String','Thickness(es) (%)','Position',[10,130,150,20],'BackgroundColor',[.8 .8 .8],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    t_start = uicontrol('Parent',run_frame2,'Style','edit','String','0','Position',[10,110,50,20],'BackgroundColor',[.95 .95 .95]);
    t_step = uicontrol('Parent',run_frame2,'Style','edit','String','1','Position',[60,110,50,20],'BackgroundColor','White');
    t_end = uicontrol('Parent',run_frame2,'Style','edit','String','0','Position',[110,110,50,20],'BackgroundColor','White');

    s_check = uicontrol('Parent',run_frame2,'Style','togglebutton','String','Sweep Angle(s) ( ° )','Position',[10,90,150,20],'BackgroundColor',[.8 .8 .8],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    s_start = uicontrol('Parent',run_frame2,'Style','edit','String','0','Position',[10,70,50,20],'BackgroundColor',[.95 .95 .95]);
    s_step = uicontrol('Parent',run_frame2,'Style','edit','String','5','Position',[60,70,50,20],'BackgroundColor','White');
    s_end = uicontrol('Parent',run_frame2,'Style','edit','String','45','Position',[110,70,50,20],'BackgroundColor','White');

    run_button = uicontrol('Parent',run_frame2,'Style','pushbutton','String','Run','Position',[10,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@generate_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    cancel_button = uicontrol('Parent',run_frame2,'Style','pushbutton','String','Cancel','Position',[170,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@end_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

    c_check = uicontrol('Parent',run_frame2,'Style','togglebutton','String','Compare to:','Position',[170,250,150,20],'BackgroundColor',[.8 .8 .8],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    filename_compare = uicontrol('Parent',run_frame2,'Style','edit','String','lrn1015','Position',[170,230,150,20],'BackgroundColor','White');

%Merge Figure

    int_fig = figure('Name','AeroMorph v.5.0|MergeAirfoils','NumberTitle','off','Position',[(sz(3)-374)/2 (sz(4)-142)/2 374142],'MenuBar','None','Visible','off');
    set(int_fig, 'color', [0 0 0]);%[.2 .4 1]
    int_frame1 = uipanel('Parent',int_fig,'Position',[.025 .025 .95 .95],'BackgroundColor',[.85 0 0]);
    int_frame2 = uipanel('Parent',int_frame1,'Position',[.025 .025 .95 .95],'BackgroundColor',[1 1 1]);

    int_airfoil_1 = uicontrol('Parent',int_frame2,'Style','edit','String',get(filename_edit,'String'),'Position',[10,90,150,20],'BackgroundColor',[1 1 1]);
    int_airfoil_2 = uicontrol('Parent',int_frame2,'Style','edit','String',get(filename_edit,'String'),'Position',[170,90,150,20],'BackgroundColor',[1 1 1]);
    int_airfoil_slider = uicontrol('Parent',int_frame2,'Style','slider','Min',0,'Max',1,'Value',0.5,'Position',[10,60,310,20],'BackgroundColor',[.8 .8 .8],'Callback',@int_airfoil_slider_callback);
    int_airfoil_percent1 = uicontrol('Parent',int_frame2,'Style','text','String',strcat(num2str(get(int_airfoil_slider,'Value')*100),'%'),'Position',[10,40,50,20],'BackgroundColor',[1 11],'HorizontalAlignment','Left','FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    int_airfoil_percent2 = uicontrol('Parent',int_frame2,'Style','text','String',strcat(num2str((1-get(int_airfoil_slider,'Value'))*100),'%'),'Position',[270,40,50,20],'BackgroundColor',[1 11],'HorizontalAlignment','Right','FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    
    int_run_button = uicontrol('Parent',int_frame2,'Style','pushbutton','String','Run','Position',[10,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@merge_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    int_cancel_button = uicontrol('Parent',int_frame2,'Style','pushbutton','String','Cancel','Position',[170,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@end_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');

%GA Figure

    ga_fig = figure('Name','AeroMorph v.5.0|GASolver','NumberTitle','off','Position',[(sz(3)-374)/2 (sz(4)-320)/2 374320],'MenuBar','None','Visible','off');
    set(ga_fig, 'color', [0 0 0]);%[.2 .4 1]
    ga_frame1 = uipanel('Parent',ga_fig,'Position',[.025 .025 .95 .95],'BackgroundColor',[.85 0 0]);
    ga_frame2 = uipanel('Parent',ga_frame1,'Position',[.025 .025 .95 .95],'BackgroundColor',[1 1 1]);

    ga_re_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Reynolds Number','Position',[10,250,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_re_value = uicontrol('Parent',ga_frame2,'Style','edit','String','5e5','Position',[10,230,150,20],'BackgroundColor',[.95 .95 .95]);

    ga_mach_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Mach Number','Position',[10,210,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_mach_value = uicontrol('Parent',ga_frame2,'Style','edit','String','0.2','Position',[10,190,150,20],'BackgroundColor',[.95 .95 .95]);

    ga_cl_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Lift Coefficient','Position',[10,170,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold','Value',1);
    ga_cl_value = uicontrol('Parent',ga_frame2,'Style','edit','String','0.4','Position',[10,150,150,20],'BackgroundColor',[.95 .95 .95]);

    ga_t_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Thickness Range(%)','Position',[170,250,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_t_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Min / Max','Position',[170,230,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_t_min = uicontrol('Parent',ga_frame2,'Style','edit','String','-4','Position',[170,210,75,20],'BackgroundColor',[.95 .95 .95]);
    ga_t_max = uicontrol('Parent',ga_frame2,'Style','edit','String','4','Position',[245,210,75,20],'BackgroundColor',[.95 .95 .95]);

    ga_s_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Sweep Angle Range(°)','Position',[170,190,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_s_caption = uicontrol('Parent',ga_frame2,'Style','text','String','Min / Max','Position',[170,170,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_s_min = uicontrol('Parent',ga_frame2,'Style','edit','String','0','Position',[170,150,75,20],'BackgroundColor',[.95 .95 .95]);
    ga_s_max = uicontrol('Parent',ga_frame2,'Style','edit','String','45','Position',[245,150,75,20],'BackgroundColor',[.95 .95 .95]);

    ga_run_button = uicontrol('Parent',ga_frame2,'Style','pushbutton','String','Optimize','Position',[10,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@ga_execute,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
    ga_cancel_button = uicontrol('Parent',ga_frame2,'Style','pushbutton','String','Cancel','Position',[170,10,150,20],'BackgroundColor',[.8 .8 .8],'Callback',@end_run,'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');


    write_log('load')
%
%
    function [] = saveoutput(save_output_button,eventdata)
        dir = cd;
        airfoildir = strcat(dir,'\airfoils');
        output_filename = get(filename_edit,'String');
        output=[xc,yc];
        save(strcat(airfoildir,'\',strcat(output_filename,'.dat')),'output','-ASCII')
        write_log('save')
    end
%
%
    function [] = exit_editor(exit_button,eventdata)
        close all; clear all; clc
    end
%
%
    function [] = reset_airfoil(reset_button,eventdata)
        xc=xc_reset;
        yc=yc_reset;
        [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
        set(incidence_value,'String',num2str(incidence_angle));
        set(camber_value,'String',num2str(max_camber));
        set(thickness_value,'String',num2str(100*(max(yc)-min(yc))));
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        set(filename_edit,'String',strcat(get(filename_load,'String'),'-AM'))
        set(sweep_value,'String','0');
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        write_log('rese')
        clc
    end
%
%
    function [] = set_thickness(thickness_edit,eventdata)
        val=get(thickness_edit,'Value');
        if val == 1
            thickness_change=0;
        elseif val == 2
            thickness_change=0.04;
        elseif val == 3
            thickness_change=0.02;
        elseif val == 4
            thickness_change=0.01;
        elseif val == 5
            thickness_change=-0.01;
        elseif val == 6
            thickness_change=-0.02;
        elseif val == 7
            thickness_change=-0.04;
        end
        set_thickness2(thickness_change)
    end
%
%
    function [] = set_thickness2(thickness_change)
        node= get(node_select,'Value');
        for i=2:length(yc)/2
            thickness(i)=yc(i)-yc(length(yc-i));
            thick_change(i)=(thickness(i)/max(thickness))*(0);
            yc(i)=yc(i)+thick_change(i);
        end
        for i=2:length(yc)/2
            thickness(i)=yc(i)-yc(length(yc-i));
            thick_change(i)=(thickness(i)/max(thickness))*(thickness_change);
            yc(i)=yc(i)+thick_change(i);
        end
        [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
        set(incidence_value,'String',num2str(incidence_angle))
        set(camber_value,'String',num2str(max_camber))
        set(node_value,'String',num2str(yc(nodes(node))));
        set(thickness_value,'String',num2str(100*(max(yc)-min(yc))));
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        set(filename_edit,'String',strcat(get(filename_load,'String'),'-AM','-t',num2str(round(str2double(get(thickness_value,'String')))),'-s',get(sweep_value,'String')));
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        write_log('topt')
    end
%
%
    function [] = topcurvefit(fit_line_button,eventdata)
        clear x_unfit y_unfit y_fit
        x_unfit=xc(1:floor(length(xc)/2+1));
        y_unfit=yc(1:floor(length(xc)/2+1));
        power=18;
        p=polyfit(x_unfit,y_unfit,power);
        for i=1:length(x_unfit)
            y(1)=p(1)*x_unfit(i)^power;
            for j=2:power
                y(j)=y(j-1)+p(j)*x_unfit(i)^(power-j+1);
            end
            y_fit(i)=y(power)+p(power+1);
        end
        yc(1:floor(length(xc)/2+1))=y_fit(1:length(y_fit));
        [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
        set(incidence_value,'String',num2str(incidence_angle))
        set(camber_value,'String',num2str(max_camber))
        set(thickness_value,'String',num2str(100*(max(yc)-min(yc))))
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        write_log('smoo')
    end
%
%
    function [] = zoom_leading(zoom_in_button,eventdata)
        fill(xc_reset,yc_reset,[.8 .8 .8]);axis([-.02 .07 -.01 .03]);
        hold on
        airfoil_plot=plot(xc,yc,'--k',xc(nodes),yc(nodes),'ko',xc(floor(1:length(xc)/2)),camber_line_0,'-b',xc(floor(1:length(xc)/2)),camber_line,'--k');axis ([-.02 .07 -.01 .03]);
        hold off
    end
%
%
    function [] = zoom_out(zoom_out_button,eventdata)
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
    end
%
%
    function [] = open_help(help_button,eventdata)
        dir = cd;
        helpdir = strcat(dir,'\help');
        dos(strcat(['notepad ' helpdir '\airfoil_editor_help.txt &']));
    end
%
%
    function [] = getnode(node_select,eventdata)
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        get_node_y=yc(nodes(node));
        set(node_value,'String',num2str(get_node_y));
    end
%
%
    function [] = setnode(node_edit,eventdata)
        clear point1xn point1y point2x point2y
        val = get(node_edit,'Value');
        node= get(node_select,'Value');
%Change Node
        if val == 1
            ychange=0;
        elseif val == 2
            ychange=0.025;
        elseif val == 3
            ychange=0.01;
        elseif val == 4
            ychange=0.005;
        elseif val == 5
            ychange=-0.005;
        elseif val == 6
            ychange=-0.01;
        elseif val == 7
            ychange=-0.025;
        end
        if node == 1 || node == 8
            disp('Endpoints cannot be changed')
        elseif node == 2 || node == 3 || node == 4 || node == 5 || node== 6 || node == 7
            yc(nodes(node))=yc(nodes(node))+ychange;
%left panel
            point1x=xc(nodes(node)+1:nodes(node-1));
            point1y=yc(nodes(node)+1:nodes(node-1));
            xpoint1=-point1x(length(point1x))+point1x(1);
            ypoint1=-point1y(length(point1y))+point1y(1);
            thetachange1=atan((ychange+ypoint1)/xpoint1)-atan(ypoint1/xpoint1);
            for i=1:length(point1x)
                thetaold1(i)=atan(point1y(i)/point1x(i));
                theta1(i)=thetachange1+thetaold1(i);
                rad1x1(i)=(sqrt(point1x(i)^2+point1y(i)^2))/cos(thetachange1);
                xnew1(i)=rad1x1(i)*cos(theta1(i));
                ynew1(i)=rad1x1(i)*sin(theta1(i));
            end
            for i=1:length(point1x)
                xnew11(i)=xnew1(i)+(point1x(length(point1x))-xnew1(length(point1x)));
                ynew11(i)=ynew1(i)+(point1y(length(point1x))-ynew1(length(point1x)));
                xc(i+nodes(node))=xnew11(i);
                yc(i+nodes(node))=ynew11(i);
            end
%right panel
            interval=nodes(node+1):nodes(node)-1;
            point2x=xc(interval);
            point2y=yc(interval);
            xpoint2=point2x(length(point2x))-point2x(1);
            ypoint2=point2y(length(point2y))-point2y(1);
            thetachange2=atan((ychange+ypoint2)/xpoint2)-atan(ypoint2/xpoint2);
            for i=1:length(point2x)
                thetaold2(i)=atan(point2y(i)/point2x(i));
                theta2(i)=thetaold2(i)+thetachange2;
                rad1x2(i)=(sqrt(point2x(i)^2+point2y(i)^2))/cos(thetachange2);
                xnew2(i)=rad1x2(i)*cos(theta2(i));
                ynew2(i)=rad1x2(i)*sin(theta2(i));
            end
            for i=1:length(point2x)
                xnew22(i)=xnew2(i)+(point2x(1)-xnew2(1));
                ynew22(i)=ynew2(i)+(point2y(1)-ynew2(1));
                xc(nodes(node+1)+i-1)=xnew22(i);
                yc(nodes(node+1)+i-1)=ynew22(i);
            end
        end
        [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
        set(incidence_value,'String',num2str(incidence_angle))
        set(camber_value,'String',num2str(max_camber))
        set(node_value,'String',num2str(yc(nodes(node))));
        set(thickness_value,'String',num2str(100*(max(yc)-min(yc))))
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        set(filename_edit,'String',strcat(get(filename_load,'String'),'-AM','-N',num2str(node)));
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        write_log('node')
    end
%
%
    function [] = load_airfoil(filename_load_button,eventdata)
        dir = cd;
        airfoildir = strcat(dir,'\airfoils');
        helpdir = strcat(dir,'\help');
        inputfile = strcat(get(filename_load,'String'),'.dat');clearcamber_line camber_line_0 max camber xc yc xc_reset yc_reset
        [xc,yc]=textread(strcat(airfoildir,'\',inputfile),'%f %f','headerlines',1);
        nodes=[floor(length(xc)/2),floor(length(xc)*(35/80)),floor(length(xc)*(29/80)),floor(length(xc)*(24/80)),floor(length(xc)*(19/80)),floor(length(xc)*(14/80)),floor(length(xc)*(8/80)),1];
        xc_reset=xc;
        yc_reset=yc;
        [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
        camber_line_0=camber_line;
        set(incidence_value,'String',num2str(incidence_angle))
        set(camber_value,'String',num2str(max_camber))
        set(thickness_value,'String',num2str(100*(max(yc)-min(yc))))
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        set(subframe2,'Title',['Editing Airfoil: ',inputfile]);
        set(subframe3,'Title','Data');
        set(filename_edit,'String',strcat(get(filename_load,'String'),'-AM'));
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        write_log('load')
    end
%
%
    function [] = plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        figure(topfig);
        axes(plot1);
        fill(xc_reset,yc_reset,[.8 .8 .8]);axis ([0 1 -.125 .225]);
        hold on
        airfoil_plot=plot(xc,yc,'--k',xc(nodes),yc(nodes),'ko',xc(floor(1:length(xc)/2)),camber_line_0,'-b',xc(floor(1:length(xc)/2)),camber_line,'--b');axis ([0 1 -.125 .225]);
        hold off
    end
%
%
    function [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc)
        for i=1:length(xc)/2
            camber_line(i,1)=(yc(i)+yc(length(yc)-i+1))/2;
        end
        max_camber= max(camber_line);
        incidence_angle=atand((camber_line(floor(length(xc)/2-1))-camber_line(floor(length(xc)/2)))/(xc(floor(length(xc)/2-1))-xc(floor(length(xc)/2))));
    end
%
%
    function [] = generate_run(run_button,eventdata)
        write_log('runx')
        count=1;
        leg={};
        AOA=[];CL=[];CD=[];CM=[];e=[];
        if get(re_check,'Value')==1;
            re_range=str2num(get(re_start,'String')):str2num(get(re_step,'String')):str2num(get(re_end,'String'));
        else
            re_range=str2num(get(re_start,'String'));
        end
        if get(mach_check,'Value')==1;
            mach_range=str2num(get(mach_start,'String')):str2num(get(mach_step,'String')):str2num(get(mach_end,'String'));
        else
            mach_range=str2num(get(mach_start,'String'));
        end
        if get(alfa_check,'Value')==1;
            alfa_x=strcat([get(alfa_start,'String'),' ',get(alfa_end,'String'),' ',(get(alfa_step,'String'))]);
            alfa_x_name=strcat([get(alfa_start,'String'),'_',get(alfa_step,'String'),'_',(get(alfa_end,'String'))]);
        else
            alfa_x=strcat([get(alfa_start,'String'),' ',get(alfa_start,'String'),' ','1']);
            alfa_x_name=get(alfa_start,'String');
        end
        if get(t_check,'Value')==1;
            t_range=str2num(get(t_start,'String'))/100:str2num(get(t_step,'String'))/100:str2num(get(t_end,'String'))/100;
        else
            t_range=str2num(get(t_start,'String'))/100;
        end
        if get(c_check,'Value')==1;
            c_range=[1,2];
        else
            c_range=1;
        end
        if get(s_check,'Value')==1;
            s_range=str2num(get(s_start,'String')):str2num(get(s_step,'String')):str2num(get(s_end,'String'));
        else
            s_range=str2num(get(s_start,'String'));
        end
        dir = cd;
        rundir = strcat(dir,'\xfoil6.96\bin');
        output=[xc,yc];
        run_base_filename = get(filename_edit,'String');
        save(strcat('airfoils','\',run_base_filename,'.dat'),'output','-ASCII');
        for c5=1:length(s_range)
            Sweep=s_range(c5);
            sweep_wing(Sweep);
            output=[xc,yc];
            run_swept_filename = get(filename_edit,'String');
            save(strcat('airfoils','\',run_swept_filename,'.dat'),'output','-ASCII');
            for c1=1:length(t_range)
                thickness_change=t_range(c1);
                set_thickness2(thickness_change)
                output=[xc,yc];
                run_filename = get(filename_edit,'String');
                save(strcat('airfoils','\',run_filename,'.dat'),'output','-ASCII');
                for c2=1:length(re_range)
                    Re=re_range(c2);
                    for c3=1:length(mach_range)
                        Mach=mach_range(c3);
                        for c4=1:length(c_range)
                            rn=c4;
                            if rn==1
                                run_filename = get(filename_edit,'String');
                            else
                                run_filename = get(filename_compare,'String');
                            end
                            run_list=char('plop','g','','load',strcat('..\..\airfoils\',run_filename,'.dat'),run_filename,'oper','visc',num2str(Re),'mach',num2str(Mach),'pacc',strcat('..\..\polars\',run_filename,'_a',alfa_x_name,'_Re',num2str(Re),'_m',num2str(Mach),'.txt'),'',['aseq ',alfa_x],'pacc','','','quit');
                            fid = fopen(strcat(rundir,'\',run_filename,'.run'),'wt');
                            for i = 1:size(run_list,1)
                                fprintf(fid,'%s\n',run_list(i,:));
                            end
                            fclose(fid);
                            run_xfoil(run_filename,Re,Mach,alfa_x_name)
                            [count,AOA,CL,CD,CM,leg,e] = read_data(AOA,CL,CD,CM,leg,count,run_filename,Re,Mach,alfa_x_name,e);
                            count=count+1;
                        end
                    end
                end
                load_airfoil(run_swept_filename)
            end
            load_airfoil(run_base_filename)
        end
        end_run(generate_run_button,eventdata)
        cl_fig=figure('Name','AeroMorph v.5.0 |Cl vs. Alpha |Cd vs. Alpha|Cm vs. Alpha |Cl/Cd vs. AOA','NumberTitle','off','Position',[100 100 1024800],'Colormap',colormap(hsv(64)));
        set(cl_fig, 'color', [1 1 1])
        colmap=colormap(jet(count));
        axes('Parent',cl_fig,'Position',[.07,.55,.42,.41]);
        for df=1:length(AOA(1,:))
            hold on
            plot(AOA(:,df),CL(:,df),'Color',colmap(df,:));
            title('C_l vs. \alpha','FontSize',8);xlabel('\alpha','FontSize',8);ylabel('C_l','FontSize',8);
            if df==length(AOA(1,:))
                legend(leg,'Location','BestOutside','FontSize',7);
            end
        end
        axes('Parent',cl_fig,'Position',[.57,.55,.42,.41]);
        for df=1:length(AOA(1,:))
            hold on
            plot(AOA(:,df),CD(:,df),'Color',colmap(df,:));
            title('C_d vs. \alpha','FontSize',8);xlabel('\alpha','FontSize',8);ylabel('C_d','FontSize',8);
            if df==length(AOA(1,:))
                legend(leg,'Location','BestOutside','FontSize',7);
            end
        end
        axes('Parent',cl_fig,'Position',[.07,.05,.42,.41]);
        for df=1:length(AOA(1,:))
            hold on
            plot(AOA(:,df),CM(:,df),'Color',colmap(df,:));
            title('C_m vs. \alpha','FontSize',8);xlabel('\alpha','FontSize',8);ylabel('C_m','FontSize',8);
            if df==length(AOA(1,:))
                legend(leg,'Location','BestOutside','FontSize',7);
            end
        end
        axes('Parent',cl_fig,'Position',[.57,.05,.42,.41]);
        for df=1:length(CD(1,:))
            hold on
            plot(CL(:,df),e(:,df),'Color',colmap(df,:));
            title('C_l / C_d vs. C_l','FontSize',8);xlabel('C_l','FontSize',8);ylabel('C_l / C_d','FontSize',8);
            if df==length(AOA(1,:))
                legend(leg,'Location','BestOutside','FontSize',7);
            end
        end
    end
%
%
    function [] = run_xfoil(run_filename,Re,Mach,alfa_x_name)
        fname=strcat('polars\',run_filename,'_a',alfa_x_name,'_Re',num2str(Re),'_m',num2str(Mach),'.txt');
        bat_file=char(['cd ','xfoil6.96\bin'],strcat('xfoil <',run_filename,'.run'));
        if exist(fname,'file')==0
            fid = fopen('run.bat','wt');
            for i = 1:size(bat_file,1)
                fprintf(fid,'%s\n',bat_file(i,:));
            end
            fclose(fid);
            dos run.bat;
        end
    end
%
%
    function [count,AOA,CL,CD,CM,leg,e] = read_data(AOA,CL,CD,CM,leg,count,run_filename,Re,Mach,alfa_x_name,e)
        fname=strcat('polars\',run_filename,'_a',alfa_x_name,'_Re',num2str(Re),'_m',num2str(Mach),'.txt');
        fid = fopen(fname);
        C = textscan(fid, '%f %f %f %f %f %f %f','HeaderLines',12);
        fclose(fid);
        legendname=strcat(run_filename,' Re-',num2str(Re),' M-',num2str(Mach));
        if count>=2 && length(C{1})<length(AOA(:,count-1))
            for adder=length(C{1})+1:length(AOA(:,count-1))
                C{1}(adder)=C{1}(length(C{1}));
                C{2}(adder)=C{2}(length(C{2}));
                C{3}(adder)=C{3}(length(C{3}));
                C{5}(adder)=C{5}(length(C{5}));
            end
        end
        if count>=2 && length(C{1})>length(AOA(:,count-1))
            AOA(:,count)=C{1}(1:length(AOA(:,count-1)));
            CL(:,count)=C{2}(1:length(CL(:,count-1)));
            CD(:,count)=C{3}(1:length(CD(:,count-1)));
            CM(:,count)=C{5}(1:length(CM(:,count-1)));
        else
            AOA(:,count)=C{1};
            CL(:,count)=C{2};
            CD(:,count)=C{3};
            CM(:,count)=C{5};
        end
        leg=[leg;{legendname}];
        for c=1:length(CL(:,count))
            e(c,count)=CL(c,count)/CD(c,count);
        end
    end
%
%
    function [] = run_select(generate_run_button,eventdata)
        set(run_fig,'Visible','on');
        set(topfig,'Visible','off');
    end
%
%
    function [] = end_run(generate_run_button,eventdata)
        set(run_fig,'Visible','off');
        set(ga_fig,'Visible','off');
        set(int_fig,'Visible','off');
        set(topfig,'Visible','on');
    end
%
%
    function [] = int_run(interpolate_button,eventdata)
        set(int_fig,'Visible','on');
        set(topfig,'Visible','off');
        set(int_airfoil_1,'String',get(filename_edit,'String'));
    end
%
%
    function [] = ga_run(ga_button,eventdata)
        set(ga_fig,'Visible','on');
        set(topfig,'Visible','off');
    end
%
%
    function [] = int_airfoil_slider_callback(int_airfoil_slider,eventdata)
        set(int_airfoil_percent1,'String',strcat(num2str(round((1-get(int_airfoil_slider,'Value'))*100)),'%'))
        set(int_airfoil_percent2,'String',strcat(num2str(round(get(int_airfoil_slider,'Value')*100)),'%'))
    end
%
%
    function [] = merge_run(int_run_button,eventdata)
        airfoil1 = get(int_airfoil_1,'String');
        airfoil2 = get(int_airfoil_2,'String');
        a1 = airfoil1(1:4);
        a2 = airfoil2(1:4);
        int_factor = num2str(round((get(int_airfoil_slider,'Value'))*100)/100);

        dir = cd;
        rundir = strcat(dir,'\xfoil6.96\bin');
        run_filename = get(filename_edit,'String');
        output=[xc,yc];
        save(strcat('airfoils','\',run_filename,'.dat'),'output','-ASCII');

        int_run_list=char('load',strcat('..\..\airfoils\',airfoil1,'.dat'),airfoil1,'inte','c','f',strcat('..\..\airfoils\',airfoil2,'.dat'),int_factor,strcat(airfoil1,'+',int_factor,airfoil2),'pcop','save',strcat('..\..\airfoils\',a1,'+',int_factor,a2,'.dat'),'','','quit');657fid = fopen(strcat('xfoil6.96\bin\morph.run'),'
        fid = fopen(strcat('xfoil6.96\bin\morph.run'),'wt');
        for i = 1:size(int_run_list,1)
            fprintf(fid,'%s\n',int_run_list(i,:));
        end
        fclose(fid);

        morph_file=char(['cd ','xfoil6.96\bin'],strcat('xfoil <morph.run'));
        fid = fopen('morph.bat','wt');
        for i = 1:size(morph_file,1)
            fprintf(fid,'%s\n',morph_file(i,:));
        end
        fclose(fid);
        dos morph.bat;

        set(filename_load,'String',strcat(a1,'+',int_factor,a2));
        load_airfoil(filename_load_button,eventdata)
        write_log('inte')
    end
%
%
    function [] = write_log(type)
        a = fix(clock);
        timestamp = strcat([num2str(a(1)),'.',num2str(a(2)),'.',num2str(a(3)),' ',num2str(a(4)),':',num2str(a(5)),':',num2str(a(6)),' $ ']);
        fname = strcat(get(filename_load,'String'),':');
        if type == 'load'
            log_line = 'Loaded Airfoil';
        elseif type == 'save'
            log_line = 'Saved Airfoil';
        elseif type == 'runx'
            log_line = 'Ran XFOIL Sequence';
        elseif type == 'inte'
            log_line = strcat(['Interpolated ',get(int_airfoil_1,'String'),' + ',get(int_airfoil_percent2,'String'),get(int_airfoil_2,'String')]);
        elseif type == 'topt'
            log_line = strcat(['Moved upper surface: New thickness ',get(thickness_value,'String'),', New camber ',get(camber_value,'String')]);
        elseif type == 'node'
            log_line = strcat(['Moved node ',num2str(get(node_select,'Value')),' to ',get(node_displacement,'String')]);
        elseif type == 'rese'
            log_line = 'Reset airfoil';
        elseif type == 'smoo'
            log_line = 'Smoothed airfoil';
        elseif type == 'swee'
            log_line = strcat(['Swept Wing ',get(sweep_value,'String'),'','Degrees: ','New thickness ',get(thickness_value,'String'),', New camber ',get(camber_value,'String')]);
        elseif type == 'gene'
            log_line = strcat(['Optimized Airfoil using GA']);
        end
        fid = fopen('logs\AM.log','at');
        fprintf(fid,'%s\n',strcat([timestamp,' ',fname,' ',log_line]));
        fclose(fid);
    end
%
%
    function [] = get_sweep_angle(sweep_wing_button,eventdata)
        sweep_angle = str2num(get(sweep_angle_box,'String'));
        sweep_wing(sweep_angle);
    end
%
%
    function [] = sweep_wing(sweep_angle)
        for c0=1:length(yc)
            yc(c0)=yc(c0)*cosd(sweep_angle);
        end
        node= get(node_select,'Value');
        [camber_line,max_camber,incidence_angle] = camber_calcs(xc,yc);
        set(incidence_value,'String',num2str(incidence_angle))
        set(camber_value,'String',num2str(max_camber))
        set(node_value,'String',num2str(yc(nodes(node))));
        set(thickness_value,'String',num2str(100*(max(yc)-min(yc))));
        node = get(node_select,'Value');
        displacement=yc(nodes(node))-yc_reset(nodes(node));
        set(node_displacement,'String',num2str(displacement));
        set(sweep_value,'String',num2str(sweep_angle));
        set(filename_edit,'String',strcat(get(filename_load,'String'),'-AM','-t',num2str(round(str2double(get(thickness_value,'String')))),'-s',get(sweep_value,'String')));
        plotter(xc,yc,xc_reset,yc_reset,camber_line,nodes,camber_line_0)
        write_log('swee');
    end
%
%
    function [] = ga_execute(ga_run_button,eventdata)
        t_min = str2num(get(ga_t_min,'String'))/100;
        t_max = str2num(get(ga_t_max,'String'))/100;
        s_min = str2num(get(ga_s_min,'String'));
        s_max = str2num(get(ga_s_max,'String'));
        num_gen=5;pop_size=20;
        ga_opts = gaoptimset('Generations',num_gen,'PopulationSize',pop_size,'StallGenLimit',3,'StallTimeLimit',Inf,'Display','iter','MutationFcn',@mutationadaptfeasible);



        ga_total = num_gen*pop_size;
        ga_progress = 0;

        ga_progressbar = waitbar(ga_progress/ga_total,'Optimizing...','Position',[50,50,300,50]);        
        [t_s_f,eff_f] = ga(@ga_fit,2,[],[],[],[],[t_min,s_min],[t_max,s_max],[],ga_opts);
        close(ga_progressbar);
        t_s_f;
        eff_f = 500-eff_f;

        reset_airfoil();
        end_run();
        set_thickness2(t_s_f(1));
        sweep_wing(t_s_f(2));
        ga_results_fig = figure('Name','AeroMorph v.5.0|GenerateRun','NumberTitle','off','Position',[(sz(3)-374)/2 (sz(4)-320)/2 sz(3)/2 sz(4)/2],'Visible','on');
        set(ga_results_fig,'color', [1 1 1]);
        ga_plot = axes('Parent',ga_results_fig,'Position',[.05,.35,.85,.55]);
        hold on
        fill(xc_reset,yc_reset,[.8 .8 .8]);axis equal;
        ga_plot=plot(xc,yc,'--k',xc(nodes),yc(nodes),'ko',xc(floor(1:length(xc)/2)),camber_line_0,'-b',xc(floor(1:length(xc)/2)),camber_line,'--b');axis equal;
        hold off

        uicontrol('Parent',ga_results_fig,'Style','text','String','SweepAngle ( ° )','Position',[10,70,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String',num2str(t_s_f(2)),'Position',[10,50,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String','MaxCamber','Position',[10,30,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String',get(camber_value,'String'),'Position',[10,10,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String','Thickness % (Total)','Position',[160,70,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String',get(thickness_value,'String'),'Position',[160,50,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String','Thickness % (Change)','Position',[160,30,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String',num2str(t_s_f(1)),'Position',[160,10,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String','Reynolds Number','Position',[310,70,150,20],'BackgroundColor',[1 1 1],'FontName','@Arial UnicodeMS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String',get(ga_re_value,'String'),'Position',[310,50,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String','MachNumber','Position',[310,30,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');
        uicontrol('Parent',ga_results_fig,'Style','text','String',get(ga_mach_value,'String'),'Position',[310,10,150,20],'BackgroundColor',[1 11],'FontName','@Arial Unicode MS','FontUnits','points','FontSize',10,'FontWeight','Bold');


        write_log('gene');
    end
%
%





