clc
clear all

load Results_Training_1_variable.mat
load Reward_Complex.mat
load Reward_bezier.mat
load Reward_Bezier_Complex.mat
%% Comparison Filtered and Original 

figure(1)
plot(Reward_00025,'linewidth',1,'Color',"#4DBEEE")
alpha(0.5)
hold on
plot(Filtered_Reward_00025,'linewidth',3,'Color','#ff8800')
grid on
xlim([0 2500])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')
legend('Original','Filtered')


%% Comparison new environment

figure(2)
plot(Filtered_Reward_00025,'linewidth',2,'Color','#ff8800')
hold on
plot(Filtered_Reward_Warning_Penalty,'linewidth',2,'Color','#7e2f8e')
hold on
plot(Filtered_Reward_No_Limits,'linewidth',2,'Color','#77ac30')
hold on
grid on
xlim([0 2000])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')
legend('Original','Penalty','No Limits')

%% Comparison new learning factors

figure(3)
plot(Filtered_Reward_No_Limits,'linewidth',2,'Color','#77ac30')
hold on
plot(Filtered_Reward_No_Limits_0005,'linewidth',2,'Color','#0072bd')
hold on
plot(Filtered_Reward_No_Limits_001,'linewidth',2,'Color','#a2142f')
hold on
grid on
xlim([0 800])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')
legend('f = 0.00025','f = 0.0005','f = 0.001')

%% Comparison different eps rate

figure(4)
plot(Filtered_Reward_No_Limits_0005,'linewidth',2,'Color','#77ac30')
hold on
plot(Filtered_Reward_No_Limits_eps_0005,'linewidth',2,'Color','k')
hold on
plot(Filtered_Reward_No_Limits_eps_001,'linewidth',2,'Color','g')
grid on
xlim([0 800])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')
legend('\epsilon = 0.001','\epsilon = 0.0005','\epsilon = 0.01')

%% Q0 graph

figure(5)
plot(Q0_00025,'linewidth',2,'Color','#4DBEEE')
hold on
plot(Q0_Warning_Penalty,'linewidth',2,'Color','#7e2f8e')
hold on
plot(Q0_Warning_No_Limits,'linewidth',2,'Color','#77ac30')
hold on
plot(Q0_Warning_No_Limits_0005,'linewidth',2,'Color','#0072bd')
hold on
plot(Q0_Warning_No_Limits_001,'linewidth',2,'Color','#a2142f')
hold on
plot(Q0_eps_0005,'linewidth',2,'Color','k')
grid on
xlim([0 2000])
ylim([0 inf])
xlabel('Episode')
ylabel('Q0')
legend('0.00025','warning','nolim 0.00025','nolim 0.0005', 'nolim 0.001','\epsilon=0.0005')

%% Comparison PPO and DQN (change colors)

figure(6)
plot(Filtered_Reward_No_Limits_0005,'linewidth',2,'Color','#ff8800')
hold on
plot(Filtered_PPO,'linewidth',2,'Color','#7e2f8e')
grid on
xlim([0 400])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')
legend('DQN','PPO')

%% 2-variables (complex)

figure(7)
plot(Filtered_Reward_complex,'linewidth',2)
hold on
grid on
xlim([0 2000])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')

%% Bezier 3-variables

figure(8)
plot(Filtered_Reward_Bezier,'LineWidth',2,'Color','#7e6f8e')
hold on
grid on
xlim([0 1000])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')

%% Bezier 4-variables (complex)

figure(9)
plot(Filtered_Reward_complex_Bezier,'LineWidth',2,'Color','#7c2f8e')
hold on
grid on
xlim([0 1000])
ylim([0 inf])
xlabel('Episode')
ylabel('Cumulative Reward')