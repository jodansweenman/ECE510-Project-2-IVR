% simulation of a put credit spread
% Enter on the first trading day of the month for first trade only,
% exit at 50% (or so) or 21 DTE, then enter next trade on the same day and 
% exit as before. Repeat

clear all 
close all
format compact
format bank

global opts  date_ent  date_exp   DTE    c_bid   c_ask    c_del    c_iv 
global stk   p_bid     p_ask      p_del  p_iv    cl_eod   cl_norm


load opts_2_data.mat % 20160701,  loads variable opts_2 (multi-year option chains) 
%   1      2         3     4      5     6      7    8     9      10     11     12    13      14
%date_ent date_exp  DTE   c_bid  c_ask  c_del  c_iv  stk  p_bid  p_ask  p_del  p_iv  cl_eod  cl_norm

opts = opts_2;
clear opts_2

date_ent=1;  date_exp=2;  DTE=3;    c_bid=4; c_ask=5;   c_del=6;    c_iv=7;
stk=8; p_bid=9; p_ask=10; p_del=11; p_iv=12; cl_eod=13; cl_norm=14;

entry_dates = @() opts(:,date_ent);  %  entry dates
exp_dates = @() opts(:,date_exp);    %  expiration dates
strks = @() opts(:,stk);             %  strikes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gets the index of the first trading day of the month
fday = find((opts(2:end,1)   - floor(opts(2:end,1)/100)* 100) < ...
            (opts(1:end-1,1) - floor(opts(1:end-1,1)/100)* 100)) + 1;
entry_date = opts(fday(1)); % first entry day
entry_IVR = opts(fday(12));
strike_away = 10;     %  change this variable for the long put
DTE_min = 21;         %  21
short_delta = 0.16;   %  0.16

Dates = unique(opts(:,1),'rows');

date_ind = find(Dates==entry_IVR);

dte=[];  nn=[];   df=[]; year_iv=[]; percent_IV=[]; sma_IV=[]; sma_IV_factor=[];
for y=1:length(Dates)
    ind4 = (entry_dates()==Dates(y));
    A_IVR = opts(ind4,:); % A contains all the options with same entry
    [~, k_IVR] = min(abs(A_IVR(:,DTE) - 45)); % find closest DTE to 45
    ind5 = (A_IVR(:,date_exp)==A_IVR(k_IVR,date_exp)); % index of options with entry +exit date
    A_IVR=A_IVR(ind5,:);%reduce A to opts with entry & exit date closest to 45 days
    
    ind3 = 1;
    min_val = 1000;
    for m=1: size(A_IVR,1)
        %A_IVR(m,8)
        temp_min = abs(A_IVR(1,13)-A_IVR(m,8));
        if temp_min < min_val
            min_val = temp_min;
            ind3 = m;
        end
    end
    trade_iv(y) = (A_IVR(ind3,7)+A_IVR(ind3,12))/2;
    year_iv = [year_iv;(A_IVR(1,1)),((A_IVR(ind3,7)+A_IVR(ind3,12))/2)];
    if y < 5
        temp_percent_IV = 0;
    else
        temp_percent_IV = abs(trade_iv(y)-trade_iv(y-4))/abs(trade_iv(y));
    end
    percent_IV = [percent_IV;(A_IVR(1,1)),temp_percent_IV];
    %iv_slope(y,1) = A_IVR(1,1);
    
    if year_iv(1,1) + 10000 <= Dates(y)
        year_iv(1,:) = [];
    end
    
    if percent_IV(1,1) + 10000 <= Dates(y)
        percent_IV(1,:) = [];
    end
%     sma_IV = [sma_IV;(A_IVR(1,1)),mean(year_iv(:,2))];
    
%     if sma_IV(1,1) + 10000 <= Dates(y)
%         sma_IV(1,:) = [];
%     end
    
%     sma_IV_factor = [sma_IV_factor;(A_IVR(1,1)),abs(trade_iv(y)-mean(year_iv(:,2)))];
    
    trade_IVR(y,1) = A_IVR(1,1);
    percent_IV_r(y,1) = A_IVR(1,1);
%     sma_IVR(y,1) = A_IVR(1,1);
%     iv_trade_slope(y,1) = A_IVR(1,1);
    if y == 1
        trade_IVR(y,2) = 0;
        percent_IV_r(y,2) = 0;
%         sma_IVR(y,2) = 0;
%         iv_trade_slope(y,2) = 0;
    else
        trade_IVR(y,2) = (trade_iv(y)-min(year_iv(:,2)))/(max(year_iv(:,2))-min(year_iv(:,2)));
        percent_IV_r(y,2) = abs(temp_percent_IV);%-mean(percent_IV(:,2)));%(temp_percent_IV-min(percent_IV(:,2)))/(max(percent_IV(:,2))-min(percent_IV(:,2)));
        %iv_slope_r(y,2) = ((trade_iv(y)-trade_iv(y-1))-min(iv_slope(:,2)))/(max(iv_slope(:,2))-min(iv_slope(:,2)));
%         sma_IVR(y,2) = (mean(sma_IV(:,2))-min(sma_IV(:,2)))/(max(sma_IV(:,2))-min(sma_IV(:,2)));
%         if y==2
%             iv_trade_slope(y,2) = 0;
%         else
%             iv_trade_slope(y,2) = (trade_iv(y)-trade_iv(y-1))/(trade_iv(y-1)-trade_iv(y-2));
%         end
    end
end

i=1;
t=1;

while entry_IVR <= 20160600
    ind1 = (entry_dates()==entry_IVR); % index of options with entry date
    A = opts(ind1,:); % A contains all the options with same entry
    [~, k] = min(abs(A(:,DTE) - 45)); % find closest DTE to 45
    ind2 = (A(:,date_exp)==A(k,date_exp)); % index of options with entry +exit date
    A=A(ind2,:);%reduce A to opts with entry & exit date closest to 45 days
    
            
    
    [~, k] = min(abs(abs(A(:,p_del)) - short_delta)); % find closest delta option
    P = A(k,:); % info for short put
    [~, k] = min(abs(abs(A(:,c_del)) - short_delta));%find index for long put 
    C = A(k,:); % info for short call
    
    idx = find(trade_IVR(:,1)==entry_IVR);
    
%     if B(10) - C(10) < strike_away
%         nn = [nn entry_date]
%         df = [df (B(10) - C(10))]
%         entry_date
%         entry_date = increment_date(entry_date, 3); % go to 7 days hence to get the right
%         AA = opts(entry_dates()>=entry_date,:);  % strike width
%         entry_date = AA(1,1);
%         dte = [dte  entry_date]
% %         keyboard
%         continue;
%     end
    
    if trade_IVR(idx,2) >= 0.40 && percent_IV_r(idx,2) < 0.10
        
        %             trade date, exp date,     strk,          premium, p/c, delta,    DTE
        tradesin{t}=[P(date_ent)  P(date_exp)  P(stk)  -P(p_bid)  0  P(p_del)  P(DTE); % short put
                     C(date_ent)  C(date_exp)  C(stk)  -C(c_bid)  1  C(c_del)  C(DTE)];% short call  

        [profit(t),tradesout{t},DIT(t),reason(t)]= ...
                               out50PercOrXDays(tradesin{t}, DTE_min);
                           
        traded_IVR(t) = trade_IVR(idx,2);
        trade_data(t,1) = traded_IVR(t);
        trade_data(t,2) = idx;
        trade_data(t,3) = profit(t);
        trade_data(t,4) = trade_iv(idx);
        trade_data(t,5) = percent_IV_r(idx,2);
        date_trades(t) = entry_IVR;
        %entry_IVR = tradesout{t}(1,1); % new entry date
        t=t+1;
        
    end
    %entry_date = tradesout{i}(1,1); % new entry date
    entry_IVR = Dates(date_ind+i);
%     n = increment_date(tradesout{i}(1,1), 1); % enter on next day
    i = i+1;
end


prob = sum(profit>0)/length(profit) * 100;
figure
bar(100*profit)

equity = 100*cumsum(profit);
figure
plot(equity)
totalprofit=equity(end)

% diary sim_results.txt
for j = 1:size(tradesin,2)
    j;
    tradesin{j};
    tradesout{j};
    [profit(j), DIT(j), reason(j)];
end
prob
totalprofit
stand_dev = std(profit)

diary off


