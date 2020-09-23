%plot DFF data

FileTag = '20257*first';
a = dir([FileTag, '*FilterAndRegisterImagesSelectROICalculateDFF.mat']);
% length(a)

for i = 1:length(a)
    i
    
    load(a(i).name);
    fig1 = figure
    plot(DFF1)
    
    ylim([-0.1, max(DFF1)+0.2]);
    ylabel('DF/F')
%     xlim([0, NofFrames]);
    xlabel('sec')
       
    ax = gca;
    xticks(ax, 0:7.57*10:length(DFF1))
    ax.XTickLabel = ax.XTick./7.57;
    ax.LineWidth = 1;
    
    position=strfind(a(i).name,'.'); 
    NewName=a(i).name(1:position-45);
    title(NewName, 'Interpreter', 'none')
    
    export_fig(fig1,[NewName '_DFFsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
    
end


