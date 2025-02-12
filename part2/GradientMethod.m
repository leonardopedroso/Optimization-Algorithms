% GradientMethod.m
%% Initialization
clear;
clc;
NDataSets = 4;

%% Setup parameters 
epsl = 1e-6; % stopping criterion
alpha_hat = 1; %initialization of alpha_k for the backtracking routine
gamma = 1e-4; % gamma of backtraking routine
beta = 0.5; % beta of backtraking routine
maxIt = [1e4; 1e4; 1e4; 1e5]; % maximum number of iterations

%% GD for each data set
for i = 1:NDataSets
    %% Upload data
    load(sprintf("./data%d.mat",i),'X','Y'); % upload data set
    K = length(Y);
    n = size(X,1);
    
    %% Set up x0 (note that x = [s;r])
    x0 = [-ones(n,1); 0];

    %% Setup objetive function and gradient
    h = [X;-ones(1,K)];
    F = @(x) (1/K)*...
        sum(log(1+exp((h'*x)'))-Y.*(h'*x)');
    gradF = @(x) (1/K)*sum((exp((h'*x)')./...
        (1+exp((h'*x)'))-Y).*h,2);
 
    %% Run GD
    fprintf("Running gradient descent for dataset %d (n = %d | K = %d).\n",...
        i,n,K);
    tic
    [xGD,ItGD,normGradGD] = gradientDescent(F,gradF,x0,epsl,...
        alpha_hat,gamma,beta,maxIt(i));
    elapsedTimeGD = toc;
    if ~isnan(xGD)
        fprintf("Gradient descent for dataset %d"+...
        " converged in %d iterations.\n",i,ItGD);
        fprintf("Elapsed time is %f seconds.\n",elapsedTimeGD);
        if i<=2
            fprintf("s = [%g; %g] | r = %g.\n",xGD(1),xGD(2),xGD(3));
        end
    else
        fprintf("Gradient descent for dataset %d "+... 
            "exceeded the maximum number of iterations.\n",i); 
        fprintf("Elapsed time is %f seconds.\n",elapsedTimeGD);
    end
    save(sprintf("./DATA/GradientDescent/GDsolDataset%d.mat",i),...
        'xGD','ItGD','normGradGD','elapsedTimeGD');
    
    %% Plot result
    plotResults = false;
    if plotResults
    if i<= 2
        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gca,'FontSize',35);
        hold on;
        ax = gca;
        ax.XGrid = 'on';
        ax.YGrid = 'on';
        axis equal;
        for k = 1:K
            if Y(k)
                scatter(X(1,k),X(2,k),200,'o','b','LineWidth',3); 
            else
                scatter(X(1,k),X(2,k),200,'o','r','LineWidth',3); 
            end
        end
        %ylim([-4 8]);
        %xlim([-4 8]);
        title(sprintf("Dataset %d",i));
        ylabel('$x_2$','Interpreter','latex');
        xlabel('$x_1$','Interpreter','latex');
        x1 = (min(X(1,:)):(max(X(1,:)-min(X(1,:))))/100:max(X(1,:)));
        plot(x1,(xGD(3)-xGD(1)*x1)/xGD(2),'--g','LineWidth',4);
        saveas(gcf,sprintf("./DATA/GradientDescent/GDsolDataset%d.fig",i));
        close(gcf);
        hold off; 
    end
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    plot(0:ItGD,normGradGD,'LineWidth',3);
    hold on;
    set(gca,'FontSize',35);
    ax = gca;
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    title(sprintf("Gradient method | Dataset %d",i));
    ylabel('$||\Delta f (s_k,r_k)||$','Interpreter','latex');
    xlabel('$k$','Interpreter','latex');
    set(gca, 'YScale', 'log');
    saveas(gcf,sprintf("./DATA/GradientDescent/GDNormGradDataset%d.fig",i));
    close(gcf);
    hold off; 
    end
    
end
