
clear all
close all
format compact
format bank

load opts_2_data.mat
% load opts_3_data.mat


%   1      2       3     4      5     6      7    8     9      10     11     12   13      14
% date  date_exp  DTE c_bid  c_ask  c_del  c_iv  stk  p_bid  p_ask  p_del  p_iv  close  close_norm

% opts_2(1000000:1000030,:)
% 
% opts_2(end-30:end,:)

unique(opts_2(:,1),'rows')

% opts_3(end-30:end,:)