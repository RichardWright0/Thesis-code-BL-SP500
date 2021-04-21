%% data retrieval
tic
c1=readtable('AAPLold.csv');
c1(2528,:)=[];%for AAPLold

% logarithmic returns of close prices
CPS=struct2array(load('CPS_240_617_1994'));
log_rets=tick2ret(CPS,datetime(c1{:,1}),'Continuous');
[m,n]=size(log_rets);
%% adjusting data for function
%prices
adjc=zeros(m+1,n);
for i=1:n
    adjc(:,i)=benford_data(CPS(:,i),'ALL',10);
end

emc_bec=zeros(9,n);
emp_bec=zeros(9,n);
for i=1:n
    bec=benford_extract(adjc(:,i),'ALL',10);
    emp_bec(:,i)=bec{:,7};
    emc_bec(:,i)=bec{:,6};
end

mean_emp_be=zeros(9,1);
for i=1:9
    adder=0;
    for j=1:n
        adder=adder+emp_bec(i,j);
    end
    mean_emp_be(i)=adder/n;
end

%log returns
emc_belrc=zeros(9,n);
emp_belrc=zeros(9,n);
for i=1:n
    belrc=benford_extract(log_rets(:,i),'ALL',10);
    emp_belrc(:,i)=belrc{:,7};
    emc_belrc(:,i)=belrc{:,6};
end

mean_lr_emp_be=zeros(9,1);
for i=1:9
    adder=0;
    for j=1:n
        adder=adder+emp_belrc(i,j);
    end
     mean_lr_emp_be(i)=adder/n;
end
%% figure overall empirical probability distributions
x=1:9;
y=0.11112*ones(size(x));
figure(1)
hold on
grid on
plot(x,mean_lr_emp_be,'b-o',x,mean_emp_be,'c-^','LineWidth',1.5)
plot(x,bec{:,3},'--k','LineWidth',1)
plot(x,y,'Color',[100 100 100]/256,'LineStyle','--','LineWidth',1)
hold off;
ylabel('\it{P_d}')
xlabel('First Significant Digit')
title('Overall Empirical Probability Distributions')
legend('Observed Log return values','Obeserved Prices Values','Benford distribution','Uniform distribution')
%% Chi-Square goodness-of-fit test
prices_multiplier=sum(emc_bec,'all');
log_multiplier=sum(emc_belrc,'all');
% Overall Log Return against Benford Dist.
CSGOF_lr_be=0;
for i=1:9
    CSGOF_lr_be=CSGOF_lr_be+(((mean_lr_emp_be(i)*log_multiplier-belrc{i,3}*log_multiplier)^2)/(belrc{i,3}*log_multiplier));
end  
% Overal Prices against Benford Dist.
CSGOF_p_be=0;
for i=1:9
    CSGOF_p_be=CSGOF_p_be+(((mean_emp_be(i)*prices_multiplier-bec{i,3}*prices_multiplier)^2)/(bec{i,3}*prices_multiplier));
end  

%Overall Log Return against Uniform Dist.
CSGOF_lr_un=0;
for i=1:9
    CSGOF_lr_un=CSGOF_lr_un+(((mean_lr_emp_be(i)*log_multiplier-0.11112*log_multiplier)^2)/(0.11112*log_multiplier));
end  
%Overal Prices against Uniform Dist.
CSGOF_p_un=0;
for i=1:9
    CSGOF_p_un=CSGOF_p_un+(((mean_emp_be(i)*prices_multiplier-0.11112*prices_multiplier)^2)/(0.11112*prices_multiplier));
end  
format bank;
varnames={'Reference Probability Distribution','Chi-Square w.r.t. Prices','Chi-Square w.r.t. Returns'};
T=table(['Benford';'Uniform'],[CSGOF_p_be;CSGOF_p_un],[CSGOF_lr_be;CSGOF_lr_un],'VariableNames',varnames) %#ok<NOPTS>

%% day-by-day analysis of log returns
dbd_emc_belrc=zeros(9,m);
for i=1:m
    belrc=benford_extract(log_rets(i,:),'ALL',10);
    dbd_emc_belrc(:,i)=belrc{:,6};
    dbd_emp_belrc(:,i)=belrc{:,7};
end
%% chi-square day-by-day log returns against benford
CSGOF_dbd=zeros(1,m);
dbd_multiplier=zeros(1,m);
accepted5=0;
accepted1=0;
rejecteddays5=0;
rejecteddays1=0;
rday1=zeros(1,m);
rday5=zeros(1,m);
t=1;
s=1;
for j=1:m
        for i=1:9
            dbd_multiplier(j)=dbd_multiplier(j)+dbd_emc_belrc(i,j);
        end
end
for j=1:m
    for i=1:9
        CSGOF_dbd(j)=CSGOF_dbd(j)+(((dbd_emc_belrc(i,j)-belrc{i,3}*dbd_multiplier).^2)/(belrc{i,3}*dbd_multiplier));
    end  
    if CSGOF_dbd(j) <= 20.0902
        accepted1=accepted1+1;
        else
            rejecteddays1=rejecteddays1+1;
            rday1(s)=j;
            s=s+1;
        end
    if CSGOF_dbd(j) <= 15.5073
        accepted5=accepted5+1;
        else
            rejecteddays5=rejecteddays5+1;
            rday5(t)=j;
            t=t+1;
        end
end
rday1=rday1(rday1~=0);
rday5=rday5(rday5~=0);
%% Consecutive rejection analysis for 5%
consecutive5=diff(rday5)==1;
consecutive1=diff(rday1)==1;
lc5=max(size(consecutive5));
lc1=max(size(consecutive1));
consec_no=zeros(30,2);
i=1;
c=1;
b=1;
while i<=lc5
    if consecutive5(i)==1
        c=2;
        i=i+1;
       while i<lc5 && consecutive5(i)==1 
       c=c+1;
        i=i+1;
       end 
       consec_no(c,1)=consec_no(c,1)+1;
    else
    consec_no(1,1)=consec_no(1,1)+1;
    i=i+1;
    end
end
i=1;
while i<=lc1
    if consecutive1(i)==1
        b=2;
        i=i+1;
       while i<lc1 && consecutive1(i)==1 
       b=b+1;
        i=i+1;
       end 
       consec_no(b,2)=consec_no(b,2)+1;
    else
    consec_no(1,2)=consec_no(1,2)+1;
    i=i+1;
    end
end
[sortedX, sortedInds] = sort(CSGOF_dbd(:),'descend');
%%
figure(2)
acceptlevel=15.51;
dates=(datetime(c1{:,1}));
dates(m,:)=[];
plotdates=linspace(dates(1),dates(end),m/121);
scatter(dates,CSGOF_dbd,10,([50,0,153]/256))
yline(15.5073,'Color',[57 255 20]/256,'lineWidth',3)
grid on
xticks(plotdates)
xtickformat('dd-MMM-yyyy')
xtickangle(45)
xlim([dates(1),dates(end)])

xlabel('Date')
ylabel('Chi-Square')
ylim([0,sortedX(1)+5])
yticks(0:20:sortedX(1)+5)
title('Chi-Square Values of the Day-by-Day Analysis of Returns')

format bank;
varnames={'Reference Probability Distribution','Chi-Square w.r.t. Prices','Chi-Square w.r.t. Returns'};
T=table(['Benford';'Uniform'],[CSGOF_p_be;CSGOF_p_un],[CSGOF_lr_be;CSGOF_lr_un],'VariableNames',varnames) %#ok<NOPTS>

figure(3)
hold on
plot(x,dbd_emp_belrc(:,sortedInds(end)),'b-o',x,dbd_emp_belrc(:,sortedInds(1)),'c-^','LineWidth',1.5)
plot(x,bec{:,3},'--k','LineWidth',1)
plot(x,y,'Color',[100 100 100]/256,'LineStyle','--','LineWidth',1)
grid on
ylabel('\it{P_d}')
xlabel('First Significant Digit')
title('Distribution of First Digit Occurence in Returns for Most and Least Accepted Days')
legend('Most Accepted Day','Least Accepted Day','Benford Distribution','Uniform Distribution')
hold off
%%
top45rd=string([45,1]);
for i=1:45
    top45rd(i)=datestr(dates(sortedInds(i)+1,1));
end
toc