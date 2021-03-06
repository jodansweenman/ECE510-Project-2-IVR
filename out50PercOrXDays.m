function [profit_out,tradesout,DIT,reason]=out50PercOrXDays(trade,DTE_min)

global opts  date_ent  date_exp  DTE    c_bid c_ask   c_del   c_iv 
global stk   p_bid     p_ask     p_del  p_iv  cl_eod  cl_norm

entry_dates = @() opts(:,date_ent);   %  entry dates
exp_dates = @() opts(:,date_exp);     %  expiration dates
strks = @() opts(:,stk);              %  strikes


%index of options with same exp. & strk as short put at a date after buy in
inda=(exp_dates()==trade(1,2))&(strks()==trade(1,3))&(entry_dates()>trade(1,1));
A = opts(inda,:);
%index of options with same exp. & strk as long put at a date after buy in
indb=(exp_dates()==trade(2,2))&(strks()==trade(2,3))&(entry_dates()>trade(2,1));
B = opts(indb,:);

if isempty(B)
    indb=(exp_dates()==trade(2,2))&(strks()==(round(trade(2,3)/5)*5))&(entry_dates()>trade(2,1));
    B = opts(indb,:);
end

premium_in = trade(1,4) + trade(2,4); % premium tradesin

if size(A,1) <= size(B,1)
    size_j = size(A,1);
else
    size_j = size(B,1);
end
%init tradesout with maxdaysout or last entry
for j = 1:size_j %  size(A,1) is # rows of A 
    % A(j,9)  ==> ask, -B(j,8) ==> bid
    %                entry_date    exp_date        strike   bid/ask      P/C  Delta      DTE
    tradeout{j} = [A(j,date_ent)  A(j,date_exp)   A(j,stk)   A(j,p_ask)   0  A(j,p_del)  A(j,DTE); 
                   B(j,date_ent)  B(j,date_exp)   B(j,stk)   B(j,c_ask)   1  B(j,c_del)  B(j,DTE)];    
             
%     premium_out(j) = tradeout{j}(1,4) + tradeout{j}(2,4);
    premium_out(j) = sum(tradeout{j}(:,4)); 
end

% tradeout{:}

% go through all possible exit trades and find first at profit target or DTE_min
i = 0;
while 1 
    i = i+1;
    if i == size(tradeout,2)
        reason = 1; % exit reason = 1 ==> reached DTE_min
        profit_out = -(premium_out(i) + premium_in);
        DIT = daysAct_num(trade(1,1), tradesout(1,1));
        return
    end
    tradesout = tradeout{i};
    if tradesout(1,7) <= DTE_min
        reason = 1; % exit reason = 1 ==> reached DTE_min
        profit_out = -(premium_out(i) + premium_in);
        DIT = daysAct_num(trade(1,1), tradesout(1,1));
        return
    end
%     if premium_out(i) <= -0.4*premium_in   %   profit target reached?
%         profit_out = -(premium_out(i) + premium_in);
%         DIT = daysAct_num(trade(1,1), tradesout(1,1));
%         reason = 2; % exit reason = 2 ==> reached profit target
%         return
%     end
end

