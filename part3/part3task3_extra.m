%% Part 3 - Task 3 - extra (part3task3_extra.m)
% Various runs can be performed. In each run the LM algorithm is run NIts
% times all for randmly generated initializations
%% Set parameters
RUN = 1; % run number 
NRuns = 1; % number of runs so far
NIts = 12; % number of times the LM algorith is called in a run
%% Load or compute data
computedD = false; % if D is already computed just load it
if ~computedD % C was not computed -> compute it now
    X = csvread("./data/data_opt.csv");
    N = size(X,1);
    D = zeros(N);
    for m = 1:N
        for n = m+1:N
           D(m,n) = norm(X(m,:)-X(n,:),2);
           D(n,m) = D(m,n);
        end
    end
    % Save data
    save("./data/distancesTask3_extra.mat",'D','N');
else % D was already computed -> compute it now
    load("./data/distancesTask3_extra.mat",'D','N');
end
%% Run various times LM for random initializations
% Set up parameters
lambda0 = 1; % initial value for lambda of the LM method

% Initialize variables to hold the solution and status parameters of the LM
% algorithm for the NIts LM calls
solLM = cell(NIts,1); % solution of the optimization problem
itLM = zeros(NIts,1); % number of iterations ran
elapsedTimeLM = zeros(NIts,1); % time elapsed running LM
costLM = cell(NIts,1); % vector of cost function values for each iteration
% vector of gradient norm of the cost function for each iteration
normGradLM = cell(NIts,1);
fprintf("-------------------- Task 3 - extra --------------------\n");
for k = 1:10
    fprintf("------------------ Solve for k=%d ------------------\n",k);
    clear objectiveF; % clear persistent variables in objectiveF
    save("./data/objectiveFData.mat",'D','N','k'); 
    maxIt = k*200; % maximum number of iterations
    epsl = k*1e-4; % stopping criterion
    parfor it = 1:NIts % calls of LM can be run in parallel
        % each entry of y is randomly generated from an uniform distribution
        % between -200 and 200
        y0 = 200*2*(rand()-0.5)*2*(rand(N*k,1)-0.5); 
        tic; % start counting LM time
        fprintf("----------------- RUN %02d - Attempt %02d "...
            +"----------------\n",RUN,it);
         % run LM method
        [solLM{it,1},itLM(it,1),costLM{it,1},normGradLM{it,1}] =...
            LMAlgorithm(lambda0,y0,epsl,maxIt);
        elapsedTimeLM(it,1) = toc; % save elapsed time
    end
    % Save whole run
    save(sprintf("./data/RunsTask3_extra/solRUN%02dk%02d.mat",RUN,k),...
        'solLM','itLM','elapsedTimeLM','costLM','normGradLM');
    %% Sort solutions found in all runs
    solSorted = zeros(NRuns*NIts,3); % sorted list of all solutions
    count = 0; % count number of solutions
    for i = 1:NRuns
       data = load(sprintf("./data/RunsTask3_extra/solRUN%02dk%02d.mat",i,k));
       for j = 1:NIts
           count = count+1;
           solSorted(count,1) = i; % 1st column has run number
           solSorted(count,2) = j; % 2nd column has attempt number within run
           solSorted(count,3) = data.costLM{j,1}(end,1);  % 2nd column has cost
       end
    end
    solSorted = sortrows(solSorted,3); % sort rows ascending cost
    save(sprintf("./data/RunsTask3_extra/solsortedk%02d.mat",k),...
        'solSorted'); % save sorted solutions
end
%% Best solutions
% Load best solution run
costTerminal = zeros(10,1);
solLM = cell(10,1);
itLM = cell(10,1);
elapsedTimeLM = cell(10,1);
costLM = cell(10,1);
normGradLM = cell(10,1);
for k = 1:8%10
    load(sprintf("./data/RunsTask3_extra/solsortedk%02d.mat",k),...
        'solSorted'); % save sorted solutions
    data = load(sprintf("./data/RunsTask3_extra/solRUN%02dk%02d.mat",solSorted(1,1),k));
    % Get best solution data and save it
    solLM{k,1} = data.solLM{solSorted(1,2),1};
    itLM{k,1} = data.itLM(solSorted(1,2),1);
    elapsedTimeLM{k,1} = data.elapsedTimeLM(solSorted(1,2),1);
    costLM{k,1} = data.costLM{solSorted(1,2),1};
    normGradLM{k,1} = data.normGradLM{solSorted(1,2),1};
    costTerminal(k) = costLM{k,1}(end);
end
% Save best solution data
save("./data/solBestTask3_extra.mat",...
     'solLM','itLM','elapsedTimeLM','costLM','normGradLM','costTerminal');

%% Plot best solution
figure('units','normalized','outerposition',[0 0 1 1]);
plot(1:8,costTerminal(1:8),'LineWidth',3);
hold on;
ylabel('$f(y)$','Interpreter','latex');
set(gca, 'YScale', 'log');
set(gca,'FontSize',35);
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on'; 
title("LM algorithm | Dataset task 1");
xlabel('$k$','Interpreter','latex');
saveas(gcf,"./data/RunsTask3_extra/task3_extra_LM.png");
close all;
hold off;

for k = 1:8
figure('units','normalized','outerposition',[0 0 1 1]);
yyaxis left
plot(0:itLM{k,1}-1,costLM{k,1},'LineWidth',3);
hold on;
ylabel('$f(y)$','Interpreter','latex');
set(gca, 'YScale', 'log');
yyaxis right
plot(0:itLM{k,1}-1,normGradLM{k,1},'LineWidth',3);
ylabel('$||\nabla f (y)||$','Interpreter','latex');
set(gca,'FontSize',35);
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on'; 
title(sprintf("LM algorithm | Dataset task 1 | k = %d",k));
set(gca, 'YScale', 'log');
xlabel('$k$','Interpreter','latex');
saveas(gcf,sprintf("./data/RunsTask3_extra/task3_extra_LM_k%02d.png",k));
close all;
hold off;
end