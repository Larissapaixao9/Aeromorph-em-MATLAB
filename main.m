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