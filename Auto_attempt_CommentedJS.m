%Begin
% Read in data
Flows=xlsread('UArk_loop_stability_hist_transect_flows_V4.xlsx');
Flows2=readtable('UArk_loop_stability_hist_transect_flows_V4.xlsx');
dismatrix1=xlsread("SFBD_DistanceMatrix Final.xlsx");
dismatrix2=readtable("SFBD_DistanceMatrix Final.xlsx");
dismatrix0=table2array(dismatrix2);
Anth=readtable("Anthropogenic_List.xlsx");
AnthV2=readtable("Anthropogenic_ListV2.xlsx");
AnthV3 = table2cell(AnthV2(:, {'Paths', 'ChannelName'}));
connections = {
'loop_000_001', 'loop_000_002', 'loop_001_002', 'loop_001_003', ...
'loop_002_004', 'loop_003_004', 'loop_003_005', 'loop_005_006', ...
'loop_004_014', 'loop_006_007', 'loop_007_008', 'loop_008_014', ...
'loop_007_009', 'loop_008_010', 'loop_009_010', 'loop_011_013', ...
'loop_011_012', 'loop_012_013', 'loop_012_014', 'loop_009_015', ...
'loop_006_037', 'loop_015_016', 'loop_016_018', 'loop_018_019', ...
'loop_010_019', 'loop_010_011', 'loop_015_020', 'loop_020_021', ...
'loop_021_022', 'loop_022_023', 'loop_023_024', 'loop_016_024', ...
'loop_018_025', 'loop_025_026', 'loop_026_027', 'loop_027_143', ...
'loop_027_028', 'loop_024_028', 'loop_021_032', 'loop_022_029', ...
'loop_029_030', 'loop_030_031', 'loop_031_032', 'loop_032_033', ...
'loop_033_034', 'loop_034_035', 'loop_035_036', 'loop_036_037', ...
'loop_020_036', 'loop_037_038', 'loop_038_039', 'loop_039_040', ...
'loop_039_041', 'loop_041_042', 'loop_042_043', 'loop_040_043', ...
'loop_042_107', 'loop_043_107', 'loop_038_044', 'loop_041_044', ...
'loop_044_114', 'loop_044_115', 'loop_107_108', 'loop_108_109', ...
'loop_108_110', 'loop_110_111', 'loop_110_113', 'loop_112_113', ...
'loop_034_046', 'loop_046_106', 'loop_045_046', 'loop_045_104', ...
'loop_046_105', 'loop_031_103', 'loop_030_102', 'loop_029_101', ...
'loop_023_047', 'loop_047_048', 'loop_048_100', 'loop_048_049', ...
'loop_049_099', 'loop_049_050', 'loop_050_067', 'loop_047_067', ...
'loop_050_051', 'loop_051_052', 'loop_052_053', 'loop_053_054', ...
'loop_052_054', 'loop_053_055', 'loop_055_145', 'loop_144_145', ...
'loop_055_144', 'loop_144_146', 'loop_060_146', 'loop_060_065', ...
'loop_065_066', 'loop_060_066', 'loop_059_060', 'loop_061_065', ...
'loop_064_066', 'loop_061_064', 'loop_059_061', 'loop_061_062', ...
'loop_062_063', 'loop_059_063', 'loop_028_062', 'loop_028_063', ...
'loop_064_067', 'loop_058_059', 'loop_057_058', 'loop_058_143', ...
'loop_019_069', 'loop_068_069', 'loop_057_068', 'loop_056_057', ...
'loop_056_145', 'loop_069_070', 'loop_068_070', 'loop_070_071', ...
'loop_068_071', 'loop_071_074', 'loop_074_075', 'loop_056_075', ...
'loop_072_074', 'loop_075_076', 'loop_072_076', 'loop_072_081', ...
'loop_076_077', 'loop_077_078', 'loop_078_079', 'loop_079_081', ...
'loop_079_080', 'loop_078_080', 'loop_081_120', 'loop_080_082', ...
'loop_082_085', 'loop_085_121', 'loop_082_083', 'loop_083_084', ...
'loop_084_087', 'loop_087_088', 'loop_086_087', 'loop_088_122', ...
'loop_086_088', 'loop_085_086', 'loop_084_090', 'loop_084_089', ...
'loop_077_089', 'loop_089_092', 'loop_091_092', 'loop_092_094', ...
'loop_093_094', 'loop_094_095', 'loop_095_096', 'loop_096_097', ...
'loop_095_097', 'loop_054_097', 'loop_051_098', 'loop_072_073', ...
'loop_073_119', 'loop_116_119', 'loop_116_117', 'loop_117_118', ...
'loop_013_117', 'loop_003_123', 'loop_123_124', 'loop_123_126', ...
'loop_125_126', 'loop_127_137', 'loop_135_136', 'loop_136_137', ...
'loop_137_138', 'loop_135_138', 'loop_128_129', 'loop_129_130', ...
'loop_130_131', 'loop_129_132', 'loop_132_133', 'loop_133_134', ...
'loop_134_135', 'loop_133_136', 'loop_134_139', 'loop_132_142', ...
'loop_130_142', 'loop_140_141', 'loop_140_142', 'loop_139_140', ...
'loop_138_139'}

% Extract unique nodes
allNodes = cellfun(@(x) regexp(x, '\d+', 'match'), connections, 'UniformOutput', false);
nodes = unique([allNodes{:}]);

for i = 1:numel(connections)
    tokens = regexp(connections{i}, 'loop_(\d+)_(\d+)', 'tokens');
    if ~isempty(tokens)
        tokens = tokens{1};
        startNode = tokens{1};
        endNode = tokens{2};
        
        startIdx = find(strcmp(nodes, startNode));
        endIdx = find(strcmp(nodes, endNode));
        
        if ~isempty(startIdx) && ~isempty(endIdx)
            adjMatrix(startIdx, endIdx) = 1;
            adjMatrix(endIdx, startIdx) = 1; % Undirected graph
        end
    end
end

% Create the graph
G = graph(adjMatrix, nodes);
cycles = allcycles(G,MaxCycleLength=25);
mincycles=cyclebasis(G);
cycles2=cell2struct(cycles','nodes',1);
mincycles2=cell2struct(mincycles','nodes',1);
for i=1:numel(cycles2);
     if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
    cycles2(i).nodes{end+1}=cycles2(i).nodes{1};
    for j = 1:size(cycles2(i).nodes,2)-1;
        startnode=str2num(cycles2(i).nodes{j});
        %cycles2(i).nodes_num(j)
        endnode=str2num(cycles2(i).nodes{j+1});
            if endnode>startnode;
                cycles2(i).loopindsder(j)=1;
                cycles2(i).LinkDists(j)=dismatrix0(startnode+2,endnode+2);
                colname=['loop_' cycles2(i).nodes{j} '_' cycles2(i).nodes{j+1}];
                colname2=find(strcmp(connections,colname));
                cycles2(i).FlowCol(j)=colname2+1;
            else
                cycles2(i).loopindsder(j)=-1;
                cycles2(i).LinkDists(j)=dismatrix0(endnode+2,startnode+2);
                colname3=['loop_' cycles2(i).nodes{j+1} '_' cycles2(i).nodes{j}];
                colname4=find(strcmp(connections,colname3));
                cycles2(i).FlowCol(j)=colname4+1;
            end
        %cycles2(i).LinkDists(j)=dismatrix0(startnode,endnode);
    end
end
%End
%Load CommentedChannelCounts, CommentedStabValues,CommentedUnstableCounts,
%and CommentedUnstableValues





%Now everything is in cycles2, ready to run stability

for i=1:length(cycles2);
     if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
     end
    flowloop0=table2array(Flows2(:,cycles2(i).FlowCol));
    dirmatrix=ones(length(flowloop0),1)*cycles2(i).loopindsder;
    flowloop=flowloop0.*dirmatrix;

    %[output outputtimeseries]=stabWSLS_v3(flowloop,cycles2(i).LinkDists);
    [output]=stabWSLS_v3(flowloop,cycles2(i).LinkDists);
    cycles2(i).stab=output;
    cycles2(i).minstab=min(output);
    %cycles2(i).timeseries=outputtimeseries;
    mean([cycles2.minstab]>0);
end

%Read in Node Coordinates
NodeCord=xlsread("Nodes with Cord.xlsx");
NodeCord2=readtable("Nodes with Cord.xlsx");
for i=1:147;
    tst=str2num(NodeCord2.Cord{i});
    NodeCord2.Long{i}=tst(1);
    NodeCord2.Lat{i}=tst(2);
end
%NodeCord2.Cord2=str2num(NodeCord2.Cord);
%[A,R2] = readgeoraster("Stability_Georaster.tif");
%geoshow(Z(:,:,1:3),R2)

%List Out Involved Channels
for i = 1:numel(cycles2)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    for j = 1:(numel(cycles2(i).nodes) - 1)
        n1 = str2double(cycles2(i).nodes{j});
        n2 = str2double(cycles2(i).nodes{j+1});
        if n1 < n2
            cycles2(i).InvolvedPaths{j} = sprintf('%d-%d', n1, n2);
        else
            cycles2(i).InvolvedPaths{j} = sprintf('%d-%d', n2, n1);
        end
    end
end

%Make Comma Seperated List for Involved Channels
for i = 1:length(cycles2)
    paths = cycles2(i).InvolvedPaths;
    strCells = cellfun(@string, paths, 'UniformOutput', false);
    cycles2(i).InvolvedPathsCommaSeparated = strjoin([strCells{:}], ', ');
end

%Determine if Loops Contain at Least 1 Anthropogenic Channel
for i = 1:numel(cycles2)
    if cycles2(i).minstab < 0
        paths = cycles2(i).InvolvedPaths;
        anthValuesV2 = AnthV2.Anth(ismember(AnthV2.Paths, paths));
        
        if any(strcmp(anthValuesV2, 'Y'))
            cycles2(i).AnthCheckV2 = 'Y';
        elseif any(strcmp(anthValuesV2, 'N'))
            cycles2(i).AnthCheckV2 = 'N';
        end
    end
end

%Calculate rootmeansq flow and determine if loops meet the high dist or low
%flow conditon
    sqFlow2=(Flows).^2;
    mFlow= mean(sqFlow2, 1);
    flowArrayV2=sqrt(mFlow);
    for i=1:numel(cycles2)
    cycles2(i).Flow2Col=cycles2(i).FlowCol-1
    end
    for i=1:numel(cycles2);
    j=cycles2(i).Flow2Col;
    cycles2(i).SqrtFlowV2=flowArrayV2(j);
    end

    sqFlow = (Flows).^2;
    sqrtflow=sqrt(sqFlow);
    flowArray = mean(sqrtflow, 1);
for i=1:numel(cycles2);
    cycles2(i).Flow2Col=cycles2(i).FlowCol-1;
end
for i=1:numel(cycles2);
    j=cycles2(i).Flow2Col;
    cycles2(i).SqrtFlow=flowArray(j);
end

for i=1:numel(cycles2);
    j=2:numel(cycles2(i).stab);
if cycles2(i).stab(j)==cycles2(i).minstab;
    cycles2(i).StabCol=j;
end
end

for i = 1:numel(cycles2);
    stab = cycles2(i).stab;
    idx = find(stab == cycles2(i).minstab, 1);
    cycles2(i).StabCol = idx; 
end


for i=1:numel(cycles2);
    j=cycles2(i).StabCol;
if cycles2(i).minstab<0;
    if cycles2(i).SqrtFlowV2(j)==min(cycles2(i).SqrtFlowV2);
        cycles2(i).LowFlowCheck='Y';
    else cycles2(i).LowFlowCheck='N';
    end
end
end

for i=1:numel(cycles2);
    j=cycles2(i).StabCol;
if cycles2(i).minstab<0;
    if cycles2(i).LinkDists(j)==max(cycles2(i).LinkDists);
        cycles2(i).HighDistCheck='Y';
    else cycles2(i).HighDistCheck='N';
    end
end
end

%Make Table Called ChannelResults with each channels total loop count,
%unstable loop count, and percentage unstable
Channels = {};
for i = 1:numel(cycles2)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    Channels = [Channels, cycles2(i).InvolvedPaths];
end
UniqueChannels = unique(Channels);

ChannelCounts = zeros(1, numel(UniqueChannels));
for j = 1:numel(UniqueChannels)
    count = 0;
    for i = 1:numel(cycles2)
        count = count + sum(strcmp(cycles2(i).InvolvedPaths, UniqueChannels{j}));
    end
    ChannelCounts(j) = count;
end

for i = 1:numel(cycles2)
    unstableList = {};
    for j = 1:numel(cycles2(i).stab)
        if cycles2(i).stab(j) < 0
            unstableList{end+1} = cycles2(i).InvolvedPaths{j};
        end
    end
    cycles2(i).UnstableChannel = unstableList;
end

UnstableChannelCounts = zeros(1, numel(UniqueChannels));
for j = 1:numel(UniqueChannels)
    Unstablecount = 0;
    for i = 1:numel(cycles2)
        if isfield(cycles2(i), 'UnstableChannel') && ~isempty(cycles2(i).UnstableChannel)
            Unstablecount = Unstablecount + sum(strcmp(cycles2(i).UnstableChannel, UniqueChannels{j}));
        end
    end
    UnstableChannelCounts(j) = Unstablecount;
end

UnstablePercent = zeros(1, numel(UniqueChannels));
for i = 1:numel(UniqueChannels)
    UnstablePercent(i) = (UnstableChannelCounts(i) / ChannelCounts(i)) * 100;
end

for i = 1:numel(UniqueChannels)
    for j = 1:size(AnthV3, 1)
        if strcmp(UniqueChannels{i}, AnthV3{j, 1}) 
            UniqueChannelNames{i} = AnthV3{j, 2}; 
        end
    end
end

%{
UnstableLongDist = zeros(1, numel(UniqueChannels));
for j = 1:numel(UniqueChannels)
    UnstableDist = 0;
    for i = 1:numel(cycles2)
        if isfield(cycles2(i), 'HighDistCheck') && ~isempty(cycles2(i).HighDistCheck)
            UnstableDist = UnstableDist + sum(strcmp(string(cycles2(i).HighDistCheck), UniqueChannels{j}));
        end
    end
    UnstableLongDist(j) = UnstableDist;
end
%}

ChannelResults = table(UniqueChannels',UniqueChannelNames', ChannelCounts', UnstableChannelCounts', UnstablePercent', ...
    'VariableNames', {'Channel','Channel Name' 'TotalCount', 'UnstableCount', 'UnstablePercent'});

%Creates cyclesUnstable which is only the loops which were unstable
cyclesun=[cycles2.minstab]<0
cyclesUnstable=cycles2(cyclesun)

%Creates cyclesLowFlow which lists all unstable loops which meet the low
%flow condition 
cyclesFlow=strcmp({cyclesUnstable.LowFlowCheck}, 'Y');
cyclesLowFlow=cyclesUnstable(cyclesFlow)

%Creates cyclesHighDist which list all unstable loops which meet the High
%Distance Condition
cyclesDist=strcmp({cyclesUnstable.HighDistCheck}, 'Y');
cyclesHighDist=cyclesUnstable(cyclesDist)

%Creates cyclesConstructed which lists all unstable loops which meet the
%Anthropogenic condition
cyclesAn=strcmp({cyclesUnstable.AnthCheckV2}, 'Y');
cyclesConstructed=cyclesUnstable(cyclesAn)

%Creates cyclesException which lists all unstable loops which do not meet
%any of the three conditions
Exception = strcmp({cyclesUnstable.HighDistCheck}, 'N') & ...
      strcmp({cyclesUnstable.LowFlowCheck}, 'N') & ...
      strcmp({cyclesUnstable.AnthCheckV2}, 'N');
cyclesException = cyclesUnstable(Exception);

%Isolates only the Unstable Channels and lists them in Unstable Channel
%Results
UnstChannels = [ChannelResults.UnstableCount] > 0;
UnstableChannelResults = ChannelResults(UnstChannels, :);

%Count the amount of conditions
for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y')
        count = count + 1;
    end
    if isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y')
        count = count + 1;
    end
    cyclesUnstable(i).ConditionCount = count;
end

% Initialize empty lists
allChannels = {};
allCounts = [];

% Loop through each struct entry
for i = 1:numel(cyclesUnstable)
    ch = cyclesUnstable(i).UnstableChannel;
    count = cyclesUnstable(i).ConditionCount;

    % If multiple channels in a cell array
    if iscell(ch)
        allChannels = [allChannels, ch];  % Append all channels
        allCounts = [allCounts, repmat(count, 1, numel(ch))];  % Duplicate count
    else
        % Single string
        allChannels{end+1} = ch;
        allCounts(end+1) = count;
    end
end

% Now get unique channels
uniqueChannels = unique(allChannels);

% Initialize output
Conditions = cell(numel(uniqueChannels), 2);  

% Compute average condition per channel
for j = 1:numel(uniqueChannels)
    channel = uniqueChannels{j};
    idx = strcmp(allChannels, channel);
    avgCondition = mean(allCounts(idx));
    Conditions{j, 1} = channel;
    Conditions{j, 2} = avgCondition;
end




%Plot of Flows through Middle River
Time=Flows2(:, "flowsInCms");
Time = Time.flowsInCms;
loop_077_089_N=Flows2.loop_077_089
figure            
set(gca,'Units','Inches','Position',[0.7 0.7 6 2]);
plot(Time,loop_077_089_N)
%xlabel('Time');
    ylabel('Flow (m^3/s)');
    %title('Flow through Middle River')
    hold on 
Size=96;
loop_077_089=movmean(Flows2.loop_077_089,Size);
plot(Time,loop_077_089)
    hold on 
%exportgraphics(gcf, 'Figures/MiddleRiverFlow.png', 'Resolution', 300);

%Looking at loops which contain Middle and Fabian
Middle_Fabian=0;
Middle_Fabian_Loops=[];
for i=1:numel(cycles2)
if any(strcmp(cycles2(i).InvolvedPaths, '77-89')) && ...
       any(strcmp(cycles2(i).InvolvedPaths, '82-83'))
        Middle_Fabian = Middle_Fabian + 1;
        Middle_Fabian_Loops(end+1)=i;
    end
end

Middle_Fabian_Unst = 0;
for i = Middle_Fabian_Loops
    if cycles2(i).minstab < 0
        Middle_Fabian_Unst = Middle_Fabian_Unst + 1;
    end
end

%Fixed Plots Begin
%Fixed DistLink Plot
%Start Figure 8
%Start Figure 9
mkdir('FixedDotPlots');
for i = 1:numel(cycles2)
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
    linkDists = cycles2(i).LinkDists; 
    totalDist = sum(linkDists);       
    
    if totalDist > 0
        normalizedDists = linkDists / totalDist; 
    else
        normalizedDists = zeros(size(linkDists)); 
    end
    
    cycles2(i).NormalizedLinkDists = normalizedDists; 
end
x_stab = [];
y_normalizedLinkDists = [];
for i = 1:numel(cycles2)
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
    x_stab = [x_stab; cycles2(i).stab(:)+1];
    y_normalizedLinkDists = [y_normalizedLinkDists; cycles2(i).NormalizedLinkDists(:)];
end

figure;
scatter(y_normalizedLinkDists, log10(x_stab));
xlabel('Normalized Link Distances');
ylabel('Log Stability');
title('Dot Plot of Link Distances vs Stability');
grid on;
%exportgraphics(gcf, 'FixedDotPlots/DistDotPlotwithBoxvCommented.png', 'Resolution', 300);

%Fixed DistLink with box
%{
figure;
hold on;
positions = [1, 2, 3, 4];
yyaxis left;
colors = repmat([253,192,134]/255, length(y_normalizedLinkDists), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_normalizedLinkDists, log10(x_stab), 30, colors);
ylabel('log_{10}(M_{ij}+1)');
yyaxis right;
boxplot(y_normalizedLinkDists(log10(x_stab)<0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab)>0 & log10(x_stab)<1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab)>1 & log10(x_stab)<2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab)>2 & log10(x_stab)<3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
ylabel('Stability Range');
xlabel('Normalized Link Distances');
set(gca, 'YTick', positions, 'YTickLabel', {'log_{10}(x_{stab}) < 0', '0 < log_{10}(x_{stab}) < 1', '1 < log_{10}(x_{stab}) < 2', 'log_{10}(x_{stab}) > 2'});
hold off;
title('Dot Plot of Link Distance vs Stability');
grid on;
%}
figure;
hold on;
positions = [-0.5, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(y_normalizedLinkDists), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_normalizedLinkDists, log10(x_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(y_normalizedLinkDists(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');
title('Dot Plot of Link Distance vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/DistDotPlotvCommented.png', 'Resolution', 300);

%NormRootMeanSq Fixed 
y_flowArray = [];

for i = 1:numel(cycles2)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end

    % Load and normalize flow
    cols = cycles2(i).FlowCol;
    flow = sqrt(mean(table2array(Flows2(:, cols)).^2));
    totalFlow = sum(flow, 2);

    if totalFlow > 0
        normalizedFlow = bsxfun(@rdivide, flow, totalFlow);
    else
        normalizedFlow = zeros(size(flow));
    end

    % Compute mean flow array and append directly to result vectors
    meanFlow = mean(normalizedFlow, 1);
    y_flowArray = [y_flowArray; meanFlow(:)];
end


% Plot
figure;
scatter(y_flowArray, log10(x_stab), 'filled');
xlabel('Normalized Flow');
ylabel('Log Stability');
title('Dot Plot of Normalized Flow vs Stability');
grid on;

%exportgraphics(gcf, 'FixedDotPlots/NormalizedFlowDotPlotvCommented.png', 'Resolution', 300);

%NormRootMeanSq Flow with Box
%{
figure;
hold on;
positions = [1, 2, 3, 4];
yyaxis left;
colors = repmat([253,192,134]/255, length(y_flowArray), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_flowArray, log10(x_stab), colors);
ylabel('log_{10}(M_{ij}+1)');
yyaxis right;
boxplot(y_flowArray(log10(x_stab)<0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab)>0 & log10(x_stab)<1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab)>1 & log10(x_stab)<2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab)>2 & log10(x_stab)<3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
ylabel('Stability Range');
xlabel('Normalized Flow');
set(gca, 'YTick', positions, 'YTickLabel', {'log_{10}(x_{stab}) < 0', '0 < log_{10}(x_{stab}) < 1', '1 < log_{10}(x_{stab}) < 2', 'log_{10}(x_{stab}) > 2'});
hold off;
title('Dot Plot of Flow vs Stability');
grid on;
%}
figure;
hold on;
positions = [-0.5, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(y_flowArray), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_flowArray, log10(x_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(y_flowArray(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{<{Q_{ab}^2}>^{0.5}}{\sum_{\mathrm{loop}} Q_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');
title('Dot Plot of Normalized Flow vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/NormalizedRootMeanSquaredFlowvCommented.png', 'Resolution', 300);

%Q/L for both normalized 
for i = 1:numel(cycles2)
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
        y_flowArrayV2 = y_flowArray(:)./ y_normalizedLinkDists(:);
end

%End Figure 8
%End Figure 9

figure;
scatter(y_flowArrayV2, log10(x_stab), 'filled');
xlabel('NormFlow/NormDist');
ylabel('Log Stability');
title('Dot Plot of NormFlow/NormDist vs Stability');
grid on;

%exportgraphics(gcf, 'FixedDotPlots/NormQ_NormLDotPlotvCommented.png', 'Resolution', 300);

%Q/L with box
%{
figure;
hold on;
positions = [1, 2, 3, 4];
yyaxis left;
colors = repmat([253,192,134]/255, length(y_flowArrayV2), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_flowArrayV2, log10(x_stab), 30, colors);
ylabel('log_{10}(M_{ij}+1)');
yyaxis right;
boxplot(y_flowArrayV2(log10(x_stab)<0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab)>0 & log10(x_stab)<1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab)>1 & log10(x_stab)<2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab)>2 & log10(x_stab)<3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
ylabel('Stability Range');
xlabel('Normalized Root Mean Squared Flow/Normalized Link Distance');
set(gca, 'YTick', positions, 'YTickLabel', {'log_{10}(x_{stab}) < 0', '0 < log_{10}(x_{stab}) < 1', '1 < log_{10}(x_{stab}) < 2', 'log_{10}(x_{stab}) > 2'});
hold off;
title('Dot Plot of Root Mean Square Flow vs Stability');
grid on;
%}
figure;
hold on;
positions = [-0.5, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(y_flowArrayV2), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_flowArrayV2, log10(x_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(y_flowArrayV2(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} Q_{ij}}}{\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');
title('Dot Plot of Root Mean Square Flow vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/L27NormalizedRootMeanSquaredFlowWithBoxvCommented.png', 'Resolution', 300);

%Check that all paths are unique 
for i=1:numel(cycles2);
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
Involved(i)=cycles2(i).InvolvedPathsCommaSeparated;
end
InvolvedUnique=unique(Involved);

%Make table for the node count statistics called NodeResults
%Start Figure 5 
for i=1:numel(cyclesUnstable)
    cyclesUnstable(i).NodeLength=length(cyclesUnstable(i).InvolvedPaths)
end

for i=1:numel(cycles2)
    cycles2(i).NodeLength=length(cycles2(i).InvolvedPaths)
end

for i=1:numel(cyclesUnstable);
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
NodeCount(i)=cyclesUnstable(i).NodeLength;
end
NodeCountUnique=unique(NodeCount);

Three=[cyclesUnstable.NodeLength]==3;
Unstable3Node=cyclesUnstable(Three);

Four=[cyclesUnstable.NodeLength]==4;
Unstable4Node=cyclesUnstable(Four);

Five=[cyclesUnstable.NodeLength]==5;
Unstable5Node=cyclesUnstable(Five);

Six=[cyclesUnstable.NodeLength]==6;
Unstable6Node=cyclesUnstable(Six);

Seven=[cyclesUnstable.NodeLength]==7;
Unstable7Node=cyclesUnstable(Seven);

Eight=[cyclesUnstable.NodeLength]==8;
Unstable8Node=cyclesUnstable(Eight);

Nine=[cyclesUnstable.NodeLength]==9;
Unstable9Node=cyclesUnstable(Nine);

Ten=[cyclesUnstable.NodeLength]==10;
Unstable10Node=cyclesUnstable(Ten);

Eleven=[cyclesUnstable.NodeLength]==11;
Unstable11Node=cyclesUnstable(Eleven);

Twelve=[cyclesUnstable.NodeLength]==12;
Unstable12Node=cyclesUnstable(Twelve);

Thirteen=[cyclesUnstable.NodeLength]==13;
Unstable13Node=cyclesUnstable(Thirteen);

Fourteen=[cyclesUnstable.NodeLength]==14;
Unstable14Node=cyclesUnstable(Fourteen);

Fifteen=[cyclesUnstable.NodeLength]==15;
Unstable15Node=cyclesUnstable(Fifteen);

Sixteen=[cyclesUnstable.NodeLength]==16;
Unstable16Node=cyclesUnstable(Sixteen);

Seventeen=[cyclesUnstable.NodeLength]==17;
Unstable17Node=cyclesUnstable(Seventeen);

Eighteen=[cyclesUnstable.NodeLength]==18;
Unstable18Node=cyclesUnstable(Eighteen);

Nineteen=[cyclesUnstable.NodeLength]==19;
Unstable19Node=cyclesUnstable(Nineteen);

Twenty=[cyclesUnstable.NodeLength]==20;
Unstable20Node=cyclesUnstable(Twenty);

TwentyOne=[cyclesUnstable.NodeLength]==21;
Unstable21Node=cyclesUnstable(TwentyOne);

TwentyTwo=[cyclesUnstable.NodeLength]==22;
Unstable22Node=cyclesUnstable(TwentyTwo);

TwentyThree=[cyclesUnstable.NodeLength]==23;
Unstable23Node=cyclesUnstable(TwentyThree);

TwentyFour=[cyclesUnstable.NodeLength]==24;
Unstable24Node=cyclesUnstable(TwentyFour);

TwentyFive=[cyclesUnstable.NodeLength]==25;
Unstable25Node=cyclesUnstable(TwentyFive);

TwentySix=[cyclesUnstable.NodeLength]==26;
Unstable26Node=cyclesUnstable(TwentySix);

TwentySeven=[cyclesUnstable.NodeLength]==27;
Unstable27Node=cyclesUnstable(TwentySeven);

ThreeT=[cycles2.NodeLength]==3;
Total3Node=cycles2(ThreeT);

FourT=[cycles2.NodeLength]==4;
Total4Node=cycles2(FourT);

FiveT=[cycles2.NodeLength]==5;
Total5Node=cycles2(FiveT);

SixT=[cycles2.NodeLength]==6;
Total6Node=cycles2(SixT);

SevenT=[cycles2.NodeLength]==7;
Total7Node=cycles2(SevenT);

EightT=[cycles2.NodeLength]==8;
Total8Node=cycles2(EightT);

NineT=[cycles2.NodeLength]==9;
Total9Node=cycles2(EightT);

TenT=[cycles2.NodeLength]==10;
Total10Node=cycles2(TenT);

ElevenT=[cycles2.NodeLength]==11;
Total11Node=cycles2(ElevenT);

TwelveT=[cycles2.NodeLength]==12;
Total12Node=cycles2(TwelveT);

ThirteenT=[cycles2.NodeLength]==13;
Total13Node=cycles2(ThirteenT);

FourteenT=[cycles2.NodeLength]==14;
Total14Node=cycles2(FourteenT);

FifteenT=[cycles2.NodeLength]==15;
Total15Node=cycles2(FifteenT);

SixteenT=[cycles2.NodeLength]==16;
Total16Node=cycles2(SixteenT);

SeventeenT=[cycles2.NodeLength]==17;
Total17Node=cycles2(SeventeenT);

EighteenT=[cycles2.NodeLength]==18;
Total18Node=cycles2(EighteenT);

NineteenT=[cycles2.NodeLength]==19;
Total19Node=cycles2(NineteenT);

TwentyT=[cycles2.NodeLength]==20;
Total20Node=cycles2(TwentyT);

TwentyOneT=[cycles2.NodeLength]==21;
Total21Node=cycles2(TwentyOneT);

TwentyTwoT=[cycles2.NodeLength]==22;
Total22Node=cycles2(TwentyTwoT);

TwentyThreeT=[cycles2.NodeLength]==23;
Total23Node=cycles2(TwentyThreeT);

TwentyFourT=[cycles2.NodeLength]==24;
Total24Node=cycles2(TwentyFourT);

TwentyFiveT=[cycles2.NodeLength]==25;
Total25Node=cycles2(TwentyFiveT);

TwentySixT=[cycles2.NodeLength]==26;
Total26Node=cycles2(TwentySixT);

TwentySevenT=[cycles2.NodeLength]==27;
Total27Node=cycles2(TwentySevenT);

NodeLength={length(Unstable3Node),length(Unstable4Node),length(Unstable5Node),length(Unstable6Node),length(Unstable7Node),length(Unstable8Node),length(Unstable9Node),length(Unstable10Node),length(Unstable11Node),length(Unstable12Node),length(Unstable13Node),length(Unstable14Node),length(Unstable15Node),length(Unstable16Node),length(Unstable17Node),length(Unstable18Node),length(Unstable19Node),length(Unstable20Node),length(Unstable21Node),length(Unstable22Node),length(Unstable23Node),length(Unstable24Node),length(Unstable25Node)}%,length(Unstable26Node),length(Unstable27Node),}
NodeLengths=cell2mat(NodeLength);
for i=1:numel(NodeLengths)
NodePercent(i)=(NodeLengths(i)/1656)*100
end

NodeLengthT={length(Total3Node),length(Total4Node),length(Total5Node),length(Total6Node),length(Total7Node),length(Total8Node),length(Total9Node),length(Total10Node),length(Total11Node),length(Total12Node),length(Total13Node),length(Total14Node),length(Total15Node),length(Total16Node),length(Total17Node),length(Total18Node),length(Total19Node),length(Total20Node),length(Total21Node),length(Total22Node),length(Total23Node),length(Total24Node),length(Total25Node)}%length(Total26Node),length(Total27Node),};
NodeLengthsT=cell2mat(NodeLengthT);
for i=1:numel(NodeLengthsT)
NodePercentT(i)=(NodeLengthsT(i)/42920)*100
end

for i=1:numel(NodeLengths);
NodePercentUnstable(i)=(NodeLengths(i)/NodeLengthsT(i))*100;
end
NodeResults = table(NodeCountUnique', NodeLength', NodeLengthT', NodePercent', NodePercentT', NodePercentUnstable', ...
    'VariableNames', {'Node Count', 'Unstable Count', 'Total Count', 'Unstable Percent', 'Total Percent', '% Unstable/Total'});

NodeBar=bar(NodeCountUnique,NodePercent)
xlabel('Node Count'); 
ylabel('Percentage of Unstable Loops (%)'); 
title('Node Count vs Percent Of All Unstable Loops'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/PerUnstLo.png', 'Resolution', 300);

NodeBar2=bar(NodeCountUnique,NodePercentUnstable)
xlabel('Node Count'); 
ylabel('Percent Unstable (%)'); 
title('Node Count vs Percent Unstable'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/PerUnst.png', 'Resolution', 300);

NodeBar3=bar(NodeCountUnique,NodePercentT)
xlabel('Node Count'); 
ylabel('Percentage of Total Loops (%)'); 
title('Node Count vs Percentage Of All Loops'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/PerTotLo.png', 'Resolution', 300);

figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2])
NodeBar3=bar(NodeCountUnique,NodePercentT);
xlabel('Node Count'); 
ylabel('Percentage of Total Loops (%)'); 
%title('Node Count vs Percentage Of All Loops'); 
grid on;

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2])
NodeBar=bar(NodeCountUnique,NodePercent);
xlabel('Node Count'); 
ylabel('Percentage of Unstable Loops (%)'); 
%title('Node Count vs Percent Of All Unstable Loops'); 
grid on;

subplot(1,3,3)
set(gca,'Units','inches','Position',[5.75 0.75 2 2])
NodeBar2=bar(NodeCountUnique,NodePercentUnstable);
xlabel('Node Count'); 
ylabel('Percent Unstable (%)'); 
%title('Node Count vs Percent Unstable'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/CombinedNode.png', 'Resolution', 300);

%mincycles stability calculation stored in mincycles2
for i=1:numel(mincycles2);
    mincycles2(i).nodes{end+1}=mincycles2(i).nodes{1};
    for j = 1:size(mincycles2(i).nodes,2)-1;
        startnode=str2num(mincycles2(i).nodes{j});
        %cycles2(i).nodes_num(j)
        endnode=str2num(mincycles2(i).nodes{j+1});
            if endnode>startnode;
                mincycles2(i).loopindsder(j)=1;
                mincycles2(i).LinkDists(j)=dismatrix0(startnode+2,endnode+2);
                colname=['loop_' mincycles2(i).nodes{j} '_' mincycles2(i).nodes{j+1}];
                colname2=find(strcmp(connections,colname));
                mincycles2(i).FlowCol(j)=colname2+1;
            else
                mincycles2(i).loopindsder(j)=-1;
                mincycles2(i).LinkDists(j)=dismatrix0(endnode+2,startnode+2);
                colname3=['loop_' mincycles2(i).nodes{j+1} '_' mincycles2(i).nodes{j}];
                colname4=find(strcmp(connections,colname3));
                mincycles2(i).FlowCol(j)=colname4+1;
            end
        %cycles2(i).LinkDists(j)=dismatrix0(startnode,endnode);
    end
end
%Now everything is in cycles2, ready to run stability

for i=1:length(mincycles2);
    flowloop0=table2array(Flows2(:,mincycles2(i).FlowCol));
    dirmatrix=ones(length(flowloop0),1)*mincycles2(i).loopindsder;
    flowloop=flowloop0.*dirmatrix;

    %[output outputtimeseries]=stabWSLS_v3(flowloop,cycles2(i).LinkDists);
    [output]=stabWSLS_v3(flowloop,mincycles2(i).LinkDists);
    mincycles2(i).stab=output;
    mincycles2(i).minstab=min(output);
    %cycles2(i).timeseries=outputtimeseries;
    mean([mincycles2.minstab]>0);
end

mincyclesun=[mincycles2.minstab]<0
mincyclesUnstable=mincycles2(mincyclesun)

for i = 1:numel(mincycles2)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    for j = 1:(numel(mincycles2(i).nodes) - 1)
        n1 = str2double(mincycles2(i).nodes{j});
        n2 = str2double(mincycles2(i).nodes{j+1});
        if n1 < n2
            mincycles2(i).InvolvedPaths{j} = sprintf('%d-%d', n1, n2);
        else
            mincycles2(i).InvolvedPaths{j} = sprintf('%d-%d', n2, n1);
        end
    end
end

for i = 1:numel(mincyclesUnstable)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    for j = 1:(numel(mincyclesUnstable(i).nodes) - 1)
        n1 = str2double(mincyclesUnstable(i).nodes{j});
        n2 = str2double(mincyclesUnstable(i).nodes{j+1});
        if n1 < n2
            mincyclesUnstable(i).InvolvedPaths{j} = sprintf('%d-%d', n1, n2);
        else
            mincyclesUnstable(i).InvolvedPaths{j} = sprintf('%d-%d', n2, n1);
        end
    end
end

for i=1:numel(mincyclesUnstable)
    mincyclesUnstable(i).NodeLength=length(mincyclesUnstable(i).InvolvedPaths)
end

for i=1:numel(mincycles2)
    mincycles2(i).NodeLength=length(mincycles2(i).InvolvedPaths)
end

for i=1:numel(mincyclesUnstable);
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cycles2));
    end
minNodeCount(i)=mincyclesUnstable(i).NodeLength;
end
minNodeCountUnique=unique(minNodeCount);

minThree = [mincyclesUnstable.NodeLength] == 3;
minUnstable3Node = mincyclesUnstable(minThree);

minFour = [mincyclesUnstable.NodeLength] == 4;
minUnstable4Node = mincyclesUnstable(minFour);

minFive = [mincyclesUnstable.NodeLength] == 5;
minUnstable5Node = mincyclesUnstable(minFive);

minSix = [mincyclesUnstable.NodeLength] == 6;
minUnstable6Node = mincyclesUnstable(minSix);

minSeven = [mincyclesUnstable.NodeLength] == 7;
minUnstable7Node = mincyclesUnstable(minSeven);

minEight = [mincyclesUnstable.NodeLength] == 8;
minUnstable8Node = mincyclesUnstable(minEight);

minNine = [mincyclesUnstable.NodeLength] == 9;
minUnstable9Node = mincyclesUnstable(minNine);

minTen = [mincyclesUnstable.NodeLength] == 10;
minUnstable10Node = mincyclesUnstable(minTen);

minEleven = [mincyclesUnstable.NodeLength] == 11;
minUnstable11Node = mincyclesUnstable(minEleven);

minTwelve = [mincyclesUnstable.NodeLength] == 12;
minUnstable12Node = mincyclesUnstable(minTwelve);

minThirteen = [mincyclesUnstable.NodeLength] == 13;
minUnstable13Node = mincyclesUnstable(minThirteen);

minFourteen = [mincyclesUnstable.NodeLength] == 14;
minUnstable14Node = mincyclesUnstable(minFourteen);

minFifteen = [mincyclesUnstable.NodeLength] == 15;
minUnstable15Node = mincyclesUnstable(minFifteen);

minSixteen = [mincyclesUnstable.NodeLength] == 16;
minUnstable16Node = mincyclesUnstable(minSixteen);

minSeventeen = [mincyclesUnstable.NodeLength] == 17;
minUnstable17Node = mincyclesUnstable(minSeventeen);

minEighteen = [mincyclesUnstable.NodeLength] == 18;
minUnstable18Node = mincyclesUnstable(minEighteen);

minNineteen = [mincyclesUnstable.NodeLength] == 19;
minUnstable19Node = mincyclesUnstable(minNineteen);

minTwenty = [mincyclesUnstable.NodeLength] == 20;
minUnstable20Node = mincyclesUnstable(minTwenty);

minTwentyOne = [mincyclesUnstable.NodeLength] == 21;
minUnstable21Node = mincyclesUnstable(minTwentyOne);

minTwentyTwo = [mincyclesUnstable.NodeLength] == 22;
minUnstable22Node = mincyclesUnstable(minTwentyTwo);

minTwentyThree = [mincyclesUnstable.NodeLength] == 23;
minUnstable23Node = mincyclesUnstable(minTwentyThree);

minTwentyFour = [mincyclesUnstable.NodeLength] == 24;
minUnstable24Node = mincyclesUnstable(minTwentyFour);

minTwentyFive = [mincyclesUnstable.NodeLength] == 25;
minUnstable25Node = mincyclesUnstable(minTwentyFive);

%minTwentySix = [mincyclesUnstable.NodeLength] == 26;
%minUnstable26Node = mincyclesUnstable(minTwentySix);

%minTwentySeven = [mincyclesUnstable.NodeLength] == 27;
%minUnstable27Node = mincyclesUnstable(minTwentySeven);

minThreeT = [mincycles2.NodeLength] == 3;
minTotal3Node = mincycles2(minThreeT);

minFourT = [mincycles2.NodeLength] == 4;
minTotal4Node = mincycles2(minFourT);

minFiveT = [mincycles2.NodeLength] == 5;
minTotal5Node = mincycles2(minFiveT);

minSixT = [mincycles2.NodeLength] == 6;
minTotal6Node = mincycles2(minSixT);

minSevenT = [mincycles2.NodeLength] == 7;
minTotal7Node = mincycles2(minSevenT);

minEightT = [mincycles2.NodeLength] == 8;
minTotal8Node = mincycles2(minEightT);

minNineT = [mincycles2.NodeLength] == 9;
minTotal9Node = mincycles2(minNineT);

minTenT = [mincycles2.NodeLength] == 10;
minTotal10Node = mincycles2(minTenT);

minElevenT = [mincycles2.NodeLength] == 11;
minTotal11Node = mincycles2(minElevenT);

minTwelveT = [mincycles2.NodeLength] == 12;
minTotal12Node = mincycles2(minTwelveT);

minThirteenT = [mincycles2.NodeLength] == 13;
minTotal13Node = mincycles2(minThirteenT);

minFourteenT = [mincycles2.NodeLength] == 14;
minTotal14Node = mincycles2(minFourteenT);

minFifteenT = [mincycles2.NodeLength] == 15;
minTotal15Node = mincycles2(minFifteenT);

minSixteenT = [mincycles2.NodeLength] == 16;
minTotal16Node = mincycles2(minSixteenT);

minSeventeenT = [mincycles2.NodeLength] == 17;
minTotal17Node = mincycles2(minSeventeenT);

minEighteenT = [mincycles2.NodeLength] == 18;
minTotal18Node = mincycles2(minEighteenT);

minNineteenT = [mincycles2.NodeLength] == 19;
minTotal19Node = mincycles2(minNineteenT);

minTwentyT = [mincycles2.NodeLength] == 20;
minTotal20Node = mincycles2(minTwentyT);

minTwentyOneT = [mincycles2.NodeLength] == 21;
minTotal21Node = mincycles2(minTwentyOneT);

minTwentyTwoT = [mincycles2.NodeLength] == 22;
minTotal22Node = mincycles2(minTwentyTwoT);

minTwentyThreeT = [mincycles2.NodeLength] == 23;
minTotal23Node = mincycles2(minTwentyThreeT);

minTwentyFourT = [mincycles2.NodeLength] == 24;
minTotal24Node = mincycles2(minTwentyFourT);

minTwentyFiveT = [mincycles2.NodeLength] == 25;
minTotal25Node = mincycles2(minTwentyFiveT);

%minTwentySixT = [mincycles2.NodeLength] == 26;
%minTotal26Node = mincycles2(minTwentySixT);

%minTwentySevenT = [mincycles2.NodeLength] == 27;
%minTotal27Node = mincycles2(minTwentySevenT);

minNodeLength = {length(minUnstable3Node), length(minUnstable4Node), length(minUnstable5Node), ...
                 length(minUnstable6Node), length(minUnstable7Node), length(minUnstable8Node), ...
                 length(minUnstable9Node), length(minUnstable10Node), length(minUnstable11Node), ...
                 length(minUnstable12Node), length(minUnstable13Node), length(minUnstable14Node), ...
                 length(minUnstable15Node), length(minUnstable16Node), length(minUnstable17Node), ...
                 length(minUnstable18Node), length(minUnstable19Node), length(minUnstable20Node), ...
                 length(minUnstable21Node), length(minUnstable22Node), length(minUnstable23Node), ...
                 length(minUnstable24Node), length(minUnstable25Node)}%,length(minUnstable26Node),length(minUnstable27Node)};
minNodeLengths=cell2mat(minNodeLength);
for i=1:numel(minNodeLengths)
minNodePercent(i)=(minNodeLengths(i)/1656)*100
end

minNodeLengthT = {length(minTotal3Node), length(minTotal4Node), length(minTotal5Node), ...
                  length(minTotal6Node), length(minTotal7Node), length(minTotal8Node), ...
                  length(minTotal9Node), length(minTotal10Node), length(minTotal11Node), ...
                  length(minTotal12Node), length(minTotal13Node), length(minTotal14Node), ...
                  length(minTotal15Node), length(minTotal16Node), length(minTotal17Node), ...
                  length(minTotal18Node), length(minTotal19Node), length(minTotal20Node), ...
                  length(minTotal21Node), length(minTotal22Node), length(minTotal23Node), ...
                  length(minTotal24Node), length(minTotal25Node)}%,length(minTotal26Node),length(minTotal27Node)};

minNodeLengthsT = cell2mat(minNodeLengthT);
for i=1:numel(minNodeLengthsT)
minNodePercentT(i)=(minNodeLengthsT(i)/19)*100
end

for i=1:numel(minNodeLengths);
minNodePercentUnstable(i)=(minNodeLengths(i)/minNodeLengthsT(i))*100;
end
%minNode=(3:27);
minNode=(3:25);
minNodeResults = table(minNode', minNodeLength', minNodeLengthT', minNodePercent', minNodePercentT', minNodePercentUnstable', ...
    'VariableNames', {'Node Count', 'Unstable Count', 'Total Count', 'Unstable Percent', 'Total Percent', '% Unstable/Total'});
%End Figure 5

minNodeBar=bar(minNode,minNodePercent)
xlabel('Node Count'); 
ylabel('Percentage of Unstable Loops (%)'); 
title('Node Count vs Percent Of All Simple Unstable Loops'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/minPerUnstLo.png', 'Resolution', 300);

minNodeBar2=bar(minNode,minNodePercentUnstable)
xlabel('Node Count'); 
ylabel('Percent Unstable (%)'); 
title('Node Count vs Percent Unstable (Simple)'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/minPerUnst.png', 'Resolution', 300);

minNodeBar3=bar(minNode,minNodePercentT)
xlabel('Node Count'); 
ylabel('Percentage of Total Loops (%)'); 
title('Node Count vs Percentage Of All Simple Loops'); 
grid on;
%exportgraphics(gcf, 'NodeGraphs/minPerTotLo.png', 'Resolution', 300);

figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2])
minNodeBar3=bar(minNode,minNodePercentT);
xlabel('Node Count'); 
ylabel('Percentage of Total Simple Loops (%)'); 
%title('Node Count vs Percentage Of All Loops'); 
grid on;

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2])
minNodeBar=bar(minNode,minNodePercent);
xlabel('Node Count'); 
ylabel('Percentage of Simple Unstable Loops (%)'); 
%title('Node Count vs Percent Of All Unstable Loops'); 
grid on;

subplot(1,3,3)
set(gca,'Units','inches','Position',[5.75 0.75 2 2])
minNodeBar2=bar(minNode,minNodePercentUnstable);
xlabel('Node Count'); 
ylabel('Percent Unstable (Simple) (%)'); 
%title('Node Count vs Percent Unstable'); 
grid on;
%}
%And Statements
for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y') && isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).FlowDist = count;
end

for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y') && isfield(cyclesUnstable(i), 'AnthCheckV2') && strcmp(cyclesUnstable(i).AnthCheckV2, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).AnFlow = count;
end

for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y') && isfield(cyclesUnstable(i), 'AnthCheckV2') && strcmp(cyclesUnstable(i).AnthCheckV2, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).AnthDist = count;
end

for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y') && isfield(cyclesUnstable(i), 'AnthCheckV2') && strcmp(cyclesUnstable(i).AnthCheckV2, 'Y') && isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).AnthDistFl = count;
end

AnFlowT=[cyclesUnstable.AnFlow]==1;
AnFlow=cyclesUnstable(AnFlowT);

AnDistT=[cyclesUnstable.AnthDist]==1;
AnDist=cyclesUnstable(AnDistT);

FlowDistT=[cyclesUnstable.FlowDist]==1;
FlowDist=cyclesUnstable(FlowDistT);

AnFlowDistT=[cyclesUnstable.AnthDistFl]==1;
AnFlowDist=cyclesUnstable(AnFlowDistT);

% Or statements
for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y') || isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).FlowODist = count;
end

for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y') || isfield(cyclesUnstable(i), 'AnthCheckV2') && strcmp(cyclesUnstable(i).AnthCheckV2, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).AnOFlow = count;
end

for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y') || isfield(cyclesUnstable(i), 'AnthCheckV2') && strcmp(cyclesUnstable(i).AnthCheckV2, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).AnthODist = count;
end


for i = 1:numel(cyclesUnstable)
    count = 0;
     if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end
    if isfield(cyclesUnstable(i), 'HighDistCheck') && strcmp(cyclesUnstable(i).HighDistCheck, 'Y') || isfield(cyclesUnstable(i), 'AnthCheckV2') && strcmp(cyclesUnstable(i).AnthCheckV2, 'Y') || isfield(cyclesUnstable(i), 'LowFlowCheck') && strcmp(cyclesUnstable(i).LowFlowCheck, 'Y')
        count = count + 1;
    end
     cyclesUnstable(i).AnthODistOFl = count;
end

AnOFlowT=[cyclesUnstable.AnOFlow]==1;
AnOFlow=cyclesUnstable(AnOFlowT);

AnODistT=[cyclesUnstable.AnthODist]==1;
AnODist=cyclesUnstable(AnODistT);

FlowODistT=[cyclesUnstable.FlowODist]==1;
FlowODist=cyclesUnstable(FlowODistT);

AnOFlowODistT=[cyclesUnstable.AnthODistOFl]==1;
AnOFlowODist=cyclesUnstable(AnOFlowODistT);

%Not Used Yet
%Colored NormAbsFlow 
%{
x_stab = [];
y_flowArray = [];
colors = [];

for i = 1:numel(cycles2)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end

    cols = cycles2(i).FlowCol;
    flow = abs(table2array(Flows2(:, cols)));
    totalFlow = sum(flow, 2);

    if totalFlow > 0
        normalizedFlow = bsxfun(@rdivide, flow, totalFlow);
    else
        normalizedFlow = zeros(size(flow));
    end

    meanFlow = mean(normalizedFlow, 1);
    stab_values = cycles2(i).stab(:);
    x_stab = [x_stab; stab_values + 1];
    y_flowArray = [y_flowArray; meanFlow(:)];

    new_colors = ones(length(stab_values), 3);
    new_colors(stab_values < 0, :) = repmat([1 0 0], sum(stab_values < 0), 1);
    new_colors(stab_values >= 0, :) = repmat([0 0 1], sum(stab_values >= 0), 1);
    colors = [colors; new_colors];
end

figure;
scatter(y_flowArray, log(x_stab), 30, colors, 'filled');
xlabel('Normalized Flow');
ylabel('Log Stability');
title('Dot Plot of Normalized Flow vs Stability (Colored)');
grid on;

exportgraphics(gcf, 'FixedDotPlots/ColoredNormFlowDotvCommented.png', 'Resolution', 300);

%Colored Link Dists
for i = 1:numel(cycles2)
    linkDists = cycles2(i).LinkDists; 
    totalDist = sum(linkDists);       
    
    if totalDist > 0
        normalizedDists = linkDists / totalDist; 
    else
        normalizedDists = zeros(size(linkDists)); 
    end
    
    cycles2(i).NormalizedLinkDists = normalizedDists; 
end

x_stab = [];
y_normalizedLinkDists = [];
colors = [];

for i = 1:numel(cycles2)
    stab_values = cycles2(i).stab(:);
    x_stab = [x_stab; stab_values + 1];  
    y_normalizedLinkDists = [y_normalizedLinkDists; cycles2(i).NormalizedLinkDists(:)];  
end

for i = 1:numel(cycles2)
    stab_values = cycles2(i).stab(:);  
    new_colors = ones(length(stab_values), 3);  

    new_colors(stab_values < 0, :) = repmat([1 0 0], sum(stab_values < 0), 1); 
    new_colors(stab_values >= 0, :) = repmat([0 0 1], sum(stab_values >= 0), 1); 
    
    colors = [colors; new_colors];  
end

figure;
scatter(y_normalizedLinkDists, log(x_stab), 30, colors, 'filled');
xlabel('Normalized Link Distances');
ylabel('Log Stability');
title('Dot Plot of Link Distances vs Stability');
grid on;
exportgraphics(gcf, 'FixedDotPlots/ColoredDistDotPlotvCommented.png', 'Resolution', 300);

%Flow diagrams of all unstable channels for full 2 years 
%Will create a seperate plot for each loop so don't run unless you have
%room for 19924 plots
mkdir('StabFigs_Flows_UnstableLoops');
mkdir('StabFigs_Flows_AllLoops');
Size = 672;  % Set the size for the moving average
for i = 1:numel(cycles2)
    nodes = cycles2(i).nodes; 
    f = figure; 
    for j = 1:length(nodes)-1
        channel_start = nodes{j};
        channel_end = nodes{j+1};
        if str2double(channel_start) > str2double(channel_end)
            temp = channel_start;
            channel_start = channel_end;
            channel_end = temp;
        end
        loop_name = ['loop_' channel_start '_' channel_end];
        disp(['Checking for loop: ', loop_name]);
        if any(strcmp(loop_name, Flows2.Properties.VariableNames))
            loop_data = Flows2{:, loop_name};  
            loop_data = movmean(loop_data, Size);
            plot(Flows2{:, 'flowsInCms'}, loop_data, 'DisplayName', ['Channel ' channel_start '-' channel_end]);
            hold on;
        else
            % If the loop doesn't exist, print a warning
            warning(['Loop ' loop_name ' not found in Flows2.']);
        end
    end
    
    xlabel('Time');
    ylabel('Q (m^{3}/s)');
    title(['Flows through Loop ' num2str(i)]);
    legend('Location', 'southeast');
    if ishandle(f)
        exportgraphics(f, fullfile('StabFigs_Flows_AllLoops', ['loop_' num2str(i) '.png']));
    end
    close(f);
end
%}

%Figure 8 Plot Start
figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2],'xScale','log')
hold on;
positions = [-0.5, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(y_normalizedLinkDists), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_normalizedLinkDists, log10(x_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(y_normalizedLinkDists(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_normalizedLinkDists(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');
%title('Dot Plot of Link Distance vs Stability');

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2],'xScale','log')
hold on;
positions = [-0.5, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(y_flowArray), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_flowArray, log10(x_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(y_flowArray(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArray(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}}$', 'Interpreter', 'latex');
%title('Dot Plot of Normalized Flow vs Stability');

%Figure 8 Plot End
%{subplot(1,3,3)
%set(gca,'Units','inches','Position',[5.75 0.75 2 2],'xScale','log')
%hold on;
%positions = [-0.5, 0.5, 1.5, 2.25];
%colors = repmat([253,192,134]/255, length(y_flowArrayV2), 1); 
%colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
%scatter(y_flowArrayV2, log10(x_stab), 30, colors);
%xLimits = xlim;
%yLimits = ylim;
%xTicks = get(gca, 'XTick');
%yTicks = get(gca, 'YTick');
%yTickLabels = get(gca, 'YTickLabel');
%boxplot(y_flowArrayV2(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
%boxplot(y_flowArrayV2(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
%boxplot(y_flowArrayV2(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
%boxplot(y_flowArrayV2(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
%xlim(xLimits);
%ylim(yLimits);
%set(gca, 'XTick', xTicks);
%set(gca, 'YTick', yTicks);
%set(gca, 'YTickLabel', yTickLabels);
%grid on;
%hold off;
%xlabel('$\frac{\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} Q_{ij}}}{\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}}$', 'Interpreter', 'latex');
%xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}} / \frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ab}^2 \rangle^{0.5}} $', 'Interpreter', 'latex');
%title('Dot Plot of Normalized Length/Normalized Root Mean Square Flow vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/CombinedDotPlots.png', 'Resolution', 300);


for i = 1:numel(cycles2)
    if any(abs(cycles2(i).minstab - (-0.0244515260078482)) < 1e-4) % Adjust tolerance if needed
        disp(i);
    end
end

disp(length(cycles2(19917).FlowCol))
disp(cycles2(19917).UnstableChannel)

for i=[19912,19913,19915,19917]
    disp(cycles2(i).LinkDists)
end

for i = 1:numel(cycles2)
    if strcmp(cycles2(i).UnstableChannel, 'N') && ...
       strcmp(cycles2(i).LowFlowCheck, 'N') && ...
       strcmp(cycles2(i).AnthCheckV2, 'N')
        disp(i);
    end
end

%Video of loops below
Paths = shaperead('../Shaw SFBD/SFBD Nodes Map/Path Files/Paths_V2.shp');
mkdir('StabFigsCommented');
f = figure;
missingPaths = {};
for i = [19912,19915,19917]
    clf;
    for j = 1:size(cycles2(i).nodes,2)-1
        s = cycles2(i).stab(j);
        startnode = str2num(cycles2(i).nodes{j});
        endnode = str2num(cycles2(i).nodes{j+1});
        pathName = sprintf('%d-%d',startnode,endnode);
        reversePathName = sprintf('%d-%d',endnode,startnode);
        pathIndex = find(strcmp({Paths.Paths},pathName) | strcmp({Paths.Paths},reversePathName));
        if ~isempty(pathIndex)
            latitudes = Paths(pathIndex).Y;
            longitudes = Paths(pathIndex).X;
            if s > 0
                geoplot(latitudes,longitudes,'g','LineWidth',2);
            else
                geoplot(latitudes,longitudes,'r','LineWidth',2);
            end
        else
            missingPaths{end+1} = pathName;
            geoplot([NodeCord2.Lat{startnode+1},NodeCord2.Lat{endnode+1}],[NodeCord2.Long{startnode+1},NodeCord2.Long{endnode+1}],'b--','LineWidth',1);
        end
        hold on;
    end
    geolimits([37.4492,38.5932],[-122.4,-121.1878]);
    exportgraphics(f,['StabFigsCommented/StabFigCommented_' num2str(i) '.png']);
end
if ~isempty(missingPaths)
    fprintf('Missing paths:\n');
    for k = 1:length(missingPaths)
        fprintf('%s\n',missingPaths{k});
    end
else
    fprintf('No missing paths detected.\n');
end

figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2])
hold on
NodeComparison=scatter(NodeCountUnique,log10(NodeLengthsT), 'filled');
NodeComparisonMin=bar(minNode,log10(minNodeLengthsT));
xlabel('Node Count'); 
ylabel('Number of log_{10}(Loops)'); 
title('Total Loops'); 
grid on
legend({'All Loops', 'Simple Loops'}, 'Location', 'best');
hold off

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2])
hold on
NodeComparisonUnstable=scatter(NodeCountUnique,log10(NodeLengths), 'filled');
NodeComparisonMinUnstable=bar(minNode,log10(minNodeLengths));
%xlabel('Node Count'); 
%ylabel('Number of log_{10}(Loops)'); 
title('Unstable Loops'); 
grid on;
hold off


%Figure 5 Plot Start
for i=1:23
    minNodePer(i)=(minNodeLengths(i)/minNodeLengthsT(i)*100);
end

for i=1:23
NodePer(i)=(NodeLengths(i)/NodeLengthsT(i))*100;
end
figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2], 'YScale','log')
semilogy(NodeCountUnique, NodeLengthsT,'b', 'LineWidth',2);
hold on
NodeComparisonMin = bar(minNode, minNodeLengthsT,'FaceColor', [1 0.5 0]);
title('Stable Loops'); 
grid on
xlabel('Loop Order')
ylabel('log_{10} Count'); 
ylim([0.8 1E4])
legend({'All Loops', 'Simple Loops'}, 'Location', 'best');
hold off

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2], 'YScale','log')
hold on
NodeComparisonUnstable=semilogy(NodeCountUnique,NodeLengths,'b','LineWidth',2);
NodeComparisonMinUnstable=bar(minNode,minNodeLengths,'FaceColor', [1 0.5 0]);
%xlabel('Node Count'); 
%ylabel('Number of log_{10}(Loops)'); 
title('Unstable Loops'); 
grid on
xlabel('Loop Order')
ylim([0.8 1E4])
hold off

subplot(1,3,3)
set(gca,'Units','inches','Position',[5.75 0.75 2 2])
hold on
bar(minNode,minNodePer, 'FaceColor', [1 0.5 0]);
plot(NodeCountUnique,NodePer, 'b','LineWidth',2);
%xlabel('Node Count'); 
xlabel('Loop Order')
ylabel('Percentage Unstable'); 
title('Percent Unstable'); 
grid on;
hold off

%Figure 5 Plot Finished


%Seperating Out Middle River
%Start Figure 10
match = arrayfun(@(x) any(strcmp(x.InvolvedPaths, '77-89')), cycles2);
cyclesMiddle = cycles2(match);

Midy_flowArray = [];

for i = 1:numel(cyclesMiddle)
    if mod(i, 500) == 0
        fprintf('Processing cycle %d of %d\n', i, numel(cycles2));
    end

    % Load and normalize flow
    cols = cyclesMiddle(i).FlowCol;
    flow = sqrt(mean(table2array(Flows2(:, cols)).^2));
    totalFlow = sum(flow, 2);

    if totalFlow > 0
        normalizedFlow = bsxfun(@rdivide, flow, totalFlow);
    else
        normalizedFlow = zeros(size(flow));
    end

    % Compute mean flow array and append directly to result vectors
    meanFlow = mean(normalizedFlow, 1);
    Midy_flowArray = [Midy_flowArray; meanFlow(:)];
end

for i = 1:numel(cyclesMiddle)
    if mod(i, 500) == 0  % Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, numel(cyclesMiddle));
    end
    
    linkDists = cyclesMiddle(i).LinkDists;  
    totalDist = sum(linkDists);        

    if totalDist > 0
        normalizedDists = linkDists / totalDist;  
    else
        normalizedDists = zeros(size(linkDists));  
    end
    
    cyclesMiddle(i).NormalizedLinkDists = normalizedDists;  
end


Midx_stab = [];
Midy_normalizedLinkDists = [];

for i = 1:numel(cyclesMiddle)  % Ensuring we're iterating over cyclesMiddle correctly
    Midx_stab = [Midx_stab; cyclesMiddle(i).stab(:) + 1];
    Midy_normalizedLinkDists = [Midy_normalizedLinkDists; cyclesMiddle(i).NormalizedLinkDists(:)];  
end

for i = 1:numel(cyclesMiddle)
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cyclesMiddle));
    end
        Midy_flowArrayV2 = Midy_flowArray(:)./ Midy_normalizedLinkDists(:);
end

% Initialize results
flowValues_7789 = [];
linkDists_7789 = [];
stabValues_7789 = [];
normalizedFlows_7789 = [];
normalizedDists_7789 = [];

targetLink = '77-89';

for i = 1:numel(cyclesMiddle)
    pathsStr = cyclesMiddle(i).InvolvedPathsCommaSeparated;

    if ~contains(pathsStr, targetLink)
        continue  % Skip cycles without 77-89
    end

    % Split path string into list of links
    linkList = strtrim(split(pathsStr, ','));

    % Find index of 77-89
    linkIdx = find(strcmp(linkList, targetLink));
    if isempty(linkIdx)
        continue
    end

    % Extract flow columns and compute all link flows
    flowCols = cyclesMiddle(i).FlowCol;
    if linkIdx > numel(flowCols) || linkIdx > numel(cyclesMiddle(i).LinkDists)
        continue
    end

    allFlows = sqrt(mean(table2array(Flows2(:, flowCols)).^2));
    totalFlow = sum(allFlows);
    flowVal = allFlows(linkIdx);  % specific flow for 77-89

    % Get all distances and total distance
    linkDists = cyclesMiddle(i).LinkDists;
    totalDist = sum(linkDists);
    distVal = linkDists(linkIdx);  % distance for 77-89

    % Extract stab value
    stabVal = cyclesMiddle(i).stab(linkIdx);

    % Store values
    flowValues_7789 = [flowValues_7789; flowVal];
    linkDists_7789 = [linkDists_7789; distVal];
    stabValues_7789 = [stabValues_7789; stabVal];

    % Store normalized values
    normalizedFlows_7789 = [normalizedFlows_7789; flowVal / totalFlow];
    normalizedDists_7789 = [normalizedDists_7789; distVal / totalDist];
end

for i = 1:numel(cyclesMiddle)
    if mod(i, 500) == 0  %Creates a processing message every 500 cycles
        fprintf('Processing cycle %d of %d\n', i, length(cyclesMiddle));
    end
        Midy_flowArrayV2_7789 = normalizedFlows_7789(:)./ normalizedDists_7789(:);
end

%End Figure 10 
%Figure 10 Plot Start
figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2],'xScale','log')
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(normalizedDists_7789), 1); 
colors(log10(stabValues_7789+1) >= 0, :) = repmat([127,201,127]/255, sum(log10(stabValues_7789+1) >= 0), 1); 
scatter(Midy_normalizedLinkDists, log10(Midx_stab), 30, [0.5,0.5,0.5]);
scatter(normalizedDists_7789, log10(stabValues_7789 + 1), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(Midy_normalizedLinkDists(log10(Midx_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_normalizedLinkDists(log10(Midx_stab) >= 0 & log10(Midx_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_normalizedLinkDists(log10(Midx_stab) >= 1 & log10(Midx_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_normalizedLinkDists(log10(Midx_stab) >= 2 & log10(Midx_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2],'xScale','log')
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(normalizedFlows_7789), 1); 
colors(log10(stabValues_7789+1) >= 0, :) = repmat([127,201,127]/255, sum(log10(stabValues_7789+1) >= 0), 1); 
scatter(Midy_flowArray, log10(Midx_stab), 30, [0.5,0.5,0.5]);
scatter(normalizedFlows_7789, log10(stabValues_7789 + 1), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(Midy_flowArray(log10(Midx_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArray(log10(Midx_stab) >= 0 & log10(Midx_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArray(log10(Midx_stab) >= 1 & log10(Midx_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArray(log10(Midx_stab) >= 2 & log10(Midx_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}}$', 'Interpreter', 'latex');
%title('Dot Plot of Normalized Flow vs Stability');

subplot(1,3,3)
set(gca,'Units','inches','Position',[5.75 0.75 2 2],'xScale','log')
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(Midy_flowArrayV2_7789), 1); 
colors(log10(stabValues_7789+1) >= 0, :) = repmat([127,201,127]/255, sum(log10(stabValues_7789+1) >= 0), 1); 
scatter(Midy_flowArrayV2, log10(Midx_stab), 30, [0.5,0.5,0.5]);
scatter(Midy_flowArrayV2_7789, log10(stabValues_7789 + 1), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(Midy_flowArrayV2(log10(Midx_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArrayV2(log10(Midx_stab) >= 0 & log10(Midx_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArrayV2(log10(Midx_stab) >= 1 & log10(Midx_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArrayV2(log10(Midx_stab) >= 2 & log10(Midx_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
%xlabel('$\frac{\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} Q_{ij}}}{\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}}$', 'Interpreter', 'latex');
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}} / \frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}} $', 'Interpreter', 'latex');
%title('Dot Plot of Normalized Length/Normalized Root Mean Square Flow vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/CombinedDotPlots.png', 'Resolution', 300);
%
%Figure 10 Plot End

% Subplot 1: Normalized Distance vs Stability
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2],'xScale','log')
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(normalizedDists_7789), 1); 
colors(log10(stabValues_7789) >= 0, :) = repmat([127,201,127]/255, sum(log10(stabValues_7789) >= 0), 1); 
scatter(normalizedDists_7789, log10(stabValues_7789 + 1), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(normalizedDists_7789(log10(stabValues_7789) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(normalizedDists_7789(log10(stabValues_7789) >= 0 & log10(stabValues_7789) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(normalizedDists_7789(log10(stabValues_7789) >= 1 & log10(stabValues_7789) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(normalizedDists_7789(log10(stabValues_7789) >= 2 & log10(stabValues_7789) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');

% Subplot 2: Normalized Flow vs Stability
subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2],'xScale','log')
hold on;
colors = repmat([253,192,134]/255, length(normalizedFlows_7789), 1); 
colors(log10(stabValues_7789) >= 0, :) = repmat([127,201,127]/255, sum(log10(stabValues_7789) >= 0), 1); 
scatter(normalizedFlows_7789, log10(stabValues_7789 + 1), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(normalizedFlows_7789(log10(stabValues_7789) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(normalizedFlows_7789(log10(stabValues_7789) >= 0 & log10(stabValues_7789) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(normalizedFlows_7789(log10(stabValues_7789) >= 1 & log10(stabValues_7789) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(normalizedFlows_7789(log10(stabValues_7789) >= 2 & log10(stabValues_7789) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}}$', 'Interpreter', 'latex');

% Subplot 3: Flow-to-Length Ratio vs Stability (Using Midy_flowArrayV2_7789)
subplot(1,3,3)
set(gca,'Units','inches','Position',[5.75 0.75 2 2],'xScale','log')
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(Midy_flowArrayV2_7789), 1); 
colors(log10(stabValues_7789) >= 0, :) = repmat([127,201,127]/255, sum(log10(stabValues_7789) >= 0), 1); 
scatter(Midy_flowArrayV2_7789, log10(stabValues_7789 + 1), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(Midy_flowArrayV2_7789(log10(stabValues_7789) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArrayV2_7789(log10(stabValues_7789) >= 0 & log10(stabValues_7789) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArrayV2_7789(log10(stabValues_7789) >= 1 & log10(stabValues_7789) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(Midy_flowArrayV2_7789(log10(stabValues_7789) >= 2 & log10(stabValues_7789) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{l_{ab}}{\sum l_{ij}} \bigg/ \frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum \langle Q_{ij}^2 \rangle^{0.5}}$', 'Interpreter', 'latex');

%Seperating Out Middle and Fabian
match = arrayfun(@(x) ...
    any(strcmp(x.InvolvedPaths, '77-89')) && ...
    any(strcmp(x.InvolvedPaths, '82-83')), ...
    cycles2);
cyclesMidFab = cycles2(match);

match = arrayfun(@(x) ...
    any(strcmp(x.InvolvedPaths, '77-89')) && ...
    any(strcmp(x.InvolvedPaths, '85-86')), ...
    cycles2);
cyclesMidOld = cycles2(match);

Midcyclesun=[cyclesMiddle.minstab]<0
cyclesMidUnstable=cyclesMiddle(Midcyclesun)


%Video of loops below
Paths = shaperead('../Shaw SFBD/SFBD Nodes Map/Path Files/Paths_V2.shp');
mkdir('StabFigsCommentedMidFab');
f = figure;
missingPaths = {};
for i = 1:numel(cyclesMidFab)
    clf;
    for j = 1:size(cyclesMidFab(i).nodes,2)-1
        s = cyclesMidFab(i).stab(j);
        startnode = str2num(cyclesMidFab(i).nodes{j});
        endnode = str2num(cyclesMidFab(i).nodes{j+1});
        pathName = sprintf('%d-%d',startnode,endnode);
        reversePathName = sprintf('%d-%d',endnode,startnode);
        pathIndex = find(strcmp({Paths.Paths},pathName) | strcmp({Paths.Paths},reversePathName));
        if ~isempty(pathIndex)
            latitudes = Paths(pathIndex).Y;
            longitudes = Paths(pathIndex).X;
            if s > 0
                geoplot(latitudes,longitudes,'g','LineWidth',2);
            else
                geoplot(latitudes,longitudes,'r','LineWidth',2);
            end
        else
            missingPaths{end+1} = pathName;
            geoplot([NodeCord2.Lat{startnode+1},NodeCord2.Lat{endnode+1}],[NodeCord2.Long{startnode+1},NodeCord2.Long{endnode+1}],'b--','LineWidth',1);
        end
        hold on;
    end
    geolimits([37.4492,38.5932],[-122.4,-121.1878]);
    exportgraphics(f,['StabFigsCommentedMidFab/StabFigCommentedMidFab_' num2str(i) '.png']);
end
if ~isempty(missingPaths)
    fprintf('Missing paths:\n');
    for k = 1:length(missingPaths)
        fprintf('%s\n',missingPaths{k});
    end
else
    fprintf('No missing paths detected.\n');
end


figure
subplot(1,3,1)
set(gca,'Units','inches','Position',[0.75 0.75 2 2])
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(TMidy_normalizedLinkDists), 1); 
colors(log10(TMidx_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(TMidx_stab) >= 0), 1); 
scatter(TMidy_normalizedLinkDists, log10(TMidx_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(TMidy_normalizedLinkDists(log10(TMidx_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_normalizedLinkDists(log10(TMidx_stab) >= 0 & log10(TMidx_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_normalizedLinkDists(log10(TMidx_stab) >= 1 & log10(TMidx_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_normalizedLinkDists(log10(TMidx_stab) >= 2 & log10(TMidx_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');

subplot(1,3,2)
set(gca,'Units','inches','Position',[3.25 0.75 2 2])
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(TMidy_flowArray), 1); 
colors(log10(TMidx_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(TMidx_stab) >= 0), 1); 
scatter(TMidy_flowArray, log10(TMidx_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(TMidy_flowArray(log10(TMidx_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_flowArray(log10(TMidx_stab) >= 0 & log10(TMidx_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_flowArray(log10(TMidx_stab) >= 1 & log10(TMidx_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_flowArray(log10(TMidx_stab) >= 2 & log10(TMidx_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
xlabel('$\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}}$', 'Interpreter', 'latex');
%title('Dot Plot of Normalized Flow vs Stability');

subplot(1,3,3)
set(gca,'Units','inches','Position',[5.75 0.75 2 2])
hold on;
positions = [0, 0.5, 1.5, 2.25];
colors = repmat([253,192,134]/255, length(TMidy_flowArrayV2), 1); 
colors(log10(TMidx_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(TMidx_stab) >= 0), 1); 
scatter(TMidy_flowArrayV2, log10(TMidx_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(TMidy_flowArrayV2(log10(TMidx_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_flowArrayV2(log10(TMidx_stab) >= 0 & log10(TMidx_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_flowArrayV2(log10(TMidx_stab) >= 1 & log10(TMidx_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(TMidy_flowArrayV2(log10(TMidx_stab) >= 2 & log10(TMidx_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
%xlabel('$\frac{\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} Q_{ij}}}{\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}}$', 'Interpreter', 'latex');
xlabel('$\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}} / \frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}} $', 'Interpreter', 'latex');
%title('Dot Plot of Normalized Length/Normalized Root Mean Square Flow vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/CombinedDotPlots.png', 'Resolution', 300);


%NormQ\NormL Fixed
%Figure 9
figure
set(gca,'Units','inches','xScale','log')
hold on;
colors = repmat([253,192,134]/255, length(y_flowArrayV2), 1); 
colors(log10(x_stab) >= 0, :) = repmat([127,201,127]/255, sum(log10(x_stab) >= 0), 1); 
scatter(y_flowArrayV2, log10(x_stab), 30, colors);
xLimits = xlim;
yLimits = ylim;
xTicks = get(gca, 'XTick');
yTicks = get(gca, 'YTick');
yTickLabels = get(gca, 'YTickLabel');
boxplot(y_flowArrayV2(log10(x_stab) < 0), 'Positions', positions(1), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab) >= 0 & log10(x_stab) < 1), 'Positions', positions(2), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab) >= 1 & log10(x_stab) < 2), 'Positions', positions(3), 'Orientation', 'horizontal', 'Symbol', '');
boxplot(y_flowArrayV2(log10(x_stab) >= 2 & log10(x_stab) < 3), 'Positions', positions(4), 'Orientation', 'horizontal', 'Symbol', '');
xlim(xLimits);
ylim(yLimits);
set(gca, 'XTick', xTicks);
set(gca, 'YTick', yTicks);
set(gca, 'YTickLabel', yTickLabels);
grid on;
hold off;
%xlabel('$\frac{\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} Q_{ij}}}{\frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}}$', 'Interpreter', 'latex');
xlabel('$\frac{\langle Q_{ab}^2 \rangle^{0.5}}{\sum_{\mathrm{loop}} \langle Q_{ij}^2 \rangle^{0.5}} / \frac{l_{ab}}{\sum_{\mathrm{loop}} l_{ij}}$', 'Interpreter', 'latex');
ylabel('log_{10}(M_{ij}+1)');
title('Dot Plot of Normalized Root Mean Square Flow/Normalized Length vs Stability');
%exportgraphics(gcf, 'FixedDotPlots/CombinedDotPlots.png', 'Resolution', 300);

mincyclesun=[mincycles2.minstab]<0
mincyclesUnstable=mincycles2(mincyclesun)

