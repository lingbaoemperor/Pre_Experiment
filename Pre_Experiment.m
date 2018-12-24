function Pre_Experiment(SubjectID,times)
%Input
if isequal(SubjectID,[])
    fprintf ('please input your name!!!');
    return
end
if ~ismember(times,[1 2 3 4])
    fprintf('times exceeded scale!!!');
    return
end
%parameter
Preferences.Times = times;
Preferences.Experiment.Name = 'TestValidPicture';
Preferences.SkipPTBSyncTests=1;
Preferences.whichScreen=0;
Preferences.Desired_Screen_Resolution_X=1536; %put the desired horizontal screen resolution here.
Preferences.Desired_Screen_Resolution_Y=864; %put the desired vertical screen resolution here.
Preferences.Desired_Screen_RefreshRate=60; %put the actual screen refresh rate here. Important for various timings.
Preferences.Screen_Distance=57; %nominal value of the screen-to-subject distance. Not important for this software, as the computer doesn't know where the subject actually is.
Preferences.SubjectID=SubjectID;
Preferences.Now = now;

%%Initialize Psychtoolbox screen
[my_window,Preferences,success]=initialize_ptb(Preferences);


Screen('BlendFunction', my_window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

cX = Preferences.Desired_Screen_Resolution_X/2;
cY = Preferences.Desired_Screen_Resolution_Y/2;

Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
ShowText = 'Loading...';
Screen('TextSize', my_window , 50);
DrawFormattedText(my_window, ShowText, 'center', cY, [0 255 255]);
Screen('Flip', my_window);

Preferences.Target.Animal.Directory = 'G:\workdoc\matlab\psychtoolbox\animal\animal\transparent_cut\';
Preferences.Target.Vehicle.Directory = 'G:\workdoc\matlab\psychtoolbox\animal\vehicle\transparent_cut\';
% Preferences.RandomSeed = sum(100*clock);
%2010的版本用getDefaultStream，暂时不知道会不会有影响
% reset(RandStream.getDefaultStream,Preferences.RandomSeed);

Preferences.Paradigm.FixationWait = 0.3;
Preferences.Paradigm.NumberOfBlocks = 1;
%分四次，所以400变成100
Preferences.Paradigm.NumberOfPerTarget = 100;
Preferences.Paradigm.NumberOfType = 4;
%每种75个，所以4种一共300
%一共多少个trial
Preferences.Paradigm.NumberOfAllTrials = Preferences.Paradigm.NumberOfType*Preferences.Paradigm.NumberOfPerTarget;
%一个block多少个trial
Preferences.Paradigm.TrialsPerBlock = 4*100/1;
%每种类型的有多少个trial，一个block中
Preferences.Paradigm.OneTypePerBlock = 100/1;

Preferences.Background.Size.X = 512;
Preferences.Background.Size.Y = 512;
%Target在左,Bk在右
Preferences.Target.Eccentricity.X = 300;
Preferences.Target.Eccentricity.Y = 0;
Preferences.Background.Eccentricity.X = -300;
Preferences.Background.Eccentricity.Y = 0;

%返回animal和bvehicle背景的对应关系、vehicle和animal背景的对应关系......
[Animal_Nature,Vehicle_Manmade,AllImages,N] = load_img_dir(Preferences);
for n = 1:N
    AllImages.Animal(n).Target = Screen('MakeTexture',my_window,squeeze(AllImages.Animal(n).Target));
    AllImages.Animal(n).Bk = Screen('MakeTexture',my_window,squeeze(AllImages.Animal(n).Bk));
end
for n = 1:N
    AllImages.Vehicle(n).Target = Screen('MakeTexture',my_window,squeeze(AllImages.Vehicle(n).Target));
    AllImages.Vehicle(n).Bk = Screen('MakeTexture',my_window,squeeze(AllImages.Vehicle(n).Bk));
end

%每种组合出现的顺序，只有一个block，所以每种300次一共1200
%aniaml和natural场景，一致
tmp = ((Preferences.Times-1)*Preferences.Paradigm.NumberOfPerTarget+1):(Preferences.Times*Preferences.Paradigm.NumberOfPerTarget);
Animal_With_Nature_Sequence = Shuffle(tmp);
Animal_With_Nature_Sequence = [Animal_With_Nature_Sequence' Animal_With_Nature_Sequence'];
%vehicle和manmade场景，一致
tmp = ((Preferences.Times-1)*Preferences.Paradigm.NumberOfPerTarget+1):(Preferences.Times*Preferences.Paradigm.NumberOfPerTarget);
Vehicle_With_Manmade_Sequence = Shuffle(tmp);
Vehicle_With_Manmade_Sequence = [Vehicle_With_Manmade_Sequence' Vehicle_With_Manmade_Sequence'];
%animal和manmade场景，不一致
tmp = ((Preferences.Times-1)*Preferences.Paradigm.NumberOfPerTarget+1):(Preferences.Times*Preferences.Paradigm.NumberOfPerTarget);
Animal_With_Manmade_Sequence = Shuffle(tmp);
[TF,LOC] = ismember(Animal_Nature(Animal_With_Manmade_Sequence,2),Vehicle_Manmade(:,1));
Animal_With_Manmade_Sequence = [Animal_With_Manmade_Sequence' LOC];
%vehicle和natural场景，不一致
tmp = ((Preferences.Times-1)*Preferences.Paradigm.NumberOfPerTarget+1):(Preferences.Times*Preferences.Paradigm.NumberOfPerTarget);
Vehicle_With_Nature_Sequence = Shuffle(tmp);
[TF,LOC] = ismember(Vehicle_Manmade(Vehicle_With_Nature_Sequence,2),Animal_Nature(:,1));
Vehicle_With_Nature_Sequence = [Vehicle_With_Nature_Sequence' LOC];
%清一下内存
clear TF;
clear LOC;
%4种组合
%每种300行5列
%分别代表：target在数组中的索引、bk在数组中的索引、target的编号、target对应背景的编号、组合类型
Type1 = [Animal_With_Nature_Sequence Animal_Nature(Animal_With_Nature_Sequence(:,1),1) Animal_Nature(Animal_With_Nature_Sequence(:,1),1) ones(Preferences.Paradigm.NumberOfPerTarget,1)];
Type2 = [Vehicle_With_Manmade_Sequence Vehicle_Manmade(Vehicle_With_Manmade_Sequence(:,1),1) Vehicle_Manmade(Vehicle_With_Manmade_Sequence(:,1),1) ones(Preferences.Paradigm.NumberOfPerTarget,1)*2];

Type3 = [Animal_With_Manmade_Sequence Animal_Nature(Animal_With_Manmade_Sequence(:,1),:) ones(Preferences.Paradigm.NumberOfPerTarget,1)*3];
Type4 = [Vehicle_With_Nature_Sequence Vehicle_Manmade(Vehicle_With_Nature_Sequence(:,1),:) ones(Preferences.Paradigm.NumberOfPerTarget,1)*4];

Base = 1;
try
    for block=1:Preferences.Paradigm.NumberOfBlocks
        %获取一个block所用的部分（四种组合）
        tmp = [Type1(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type2(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type3(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:);...
        Type4(Base:Base+Preferences.Paradigm.OneTypePerBlock-1,:)];
        %再次打乱一下顺序
        Preferences.Block(block).Trials = Shuffle(tmp,2);
        Base = Base+Preferences.Paradigm.OneTypePerBlock;
        trial = 1;
        while trial <= Preferences.Paradigm.TrialsPerBlock
            %获取target在数组中的索引和背景的索引
            target_index = Preferences.Block(block).Trials(trial,1);
            exp_index = Preferences.Block(block).Trials(trial,2);
            switch Preferences.Block(block).Trials(trial,5)
                case 1
                    Target = AllImages.Animal(target_index).Target;
                    h = AllImages.Animal(target_index).Target_Size(1);
                    w = AllImages.Animal(target_index).Target_Size(2);
                    Bk = AllImages.Animal(exp_index).Bk;
                case 2
                    Target = AllImages.Vehicle(target_index).Target;
                    h = AllImages.Vehicle(target_index).Target_Size(1);
                    w = AllImages.Vehicle(target_index).Target_Size(2);
                    Bk = AllImages.Vehicle(exp_index).Bk;
                case 3
                    Target = AllImages.Animal(target_index).Target;
                    h = AllImages.Animal(target_index).Target_Size(1);
                    w = AllImages.Animal(target_index).Target_Size(2);
                    Bk = AllImages.Vehicle(exp_index).Bk;
                case 4
                    Target = AllImages.Vehicle(target_index).Target;
                    h = AllImages.Vehicle(target_index).Target_Size(1);
                    w = AllImages.Vehicle(target_index).Target_Size(2);
                    Bk = AllImages.Animal(exp_index).Bk;
                otherwise
                    fprintf('Error!!!');
                    clear;
                    Screen('CloseAll');
                    sca
            end
            %fixation
            Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
            Screen('DrawLine', my_window, [255 255 255],cX,cY-7,cX,cY+6,3);
            Screen('DrawLine', my_window, [255 255 255],cX-7,cY,cX+6,cY,3);
            Screen('Flip',my_window);
%             WaitSecs(Preferences.Paradigm.FixationWait+rand(1)*0.2);
            %stimuli
            frames = 0;
            while(true)
                if(frames < 600000)
                    frames = frames+1;
                end
                Screen('FillRect', my_window, [127 127 127],[cX-Preferences.Desired_Screen_Resolution_X/2,cY-Preferences.Desired_Screen_Resolution_Y/2,cX+Preferences.Desired_Screen_Resolution_X/2,cY+Preferences.Desired_Screen_Resolution_Y/2]);
                Screen('DrawTexture', my_window, Target, [], [cX-Preferences.Target.Eccentricity.X-w/2, cY-Preferences.Target.Eccentricity.Y-h/2, cX-Preferences.Target.Eccentricity.X+w/2-1, cY-Preferences.Target.Eccentricity.Y+h/2-1]);
                Screen('DrawTexture', my_window, Bk, [], [cX-Preferences.Background.Eccentricity.X-Preferences.Background.Size.X/2, cY-Preferences.Target.Eccentricity.Y-Preferences.Background.Size.Y/2, cX-Preferences.Background.Eccentricity.X+Preferences.Background.Size.X/2-1, cY-Preferences.Background.Eccentricity.Y+Preferences.Background.Size.Y/2-1]);
                Screen('Flip',my_window);
                %等待按键
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(0);
                if(~keyIsDown)
                    continue
                end
                response = KbName(keyCode);
                if isequal(response,'up')
                    Preferences.Block(block).Trials(trial,6) = 1;
                    Preferences.Block(block).Trials(trial,7) = frames;
                    trial = trial+1;
                    break;
                elseif isequal(response,'down')
                    Preferences.Block(block).Trials(trial,6) = 2;
                    Preferences.Block(block).Trials(trial,7) = frames;
                    trial = trial+1;
                    break;
                elseif isequal(response,'space') && trial > 1
                    trial = trial-1;
                    break;
                else
                    continue;
                end
                break;
            end
            Preferences.Block(block).Trials(trial,7)=0;
            trial = trial+1;
        end
    end
save([Preferences.SubjectID '_' num2str(Preferences.Times) '_' datestr(Preferences.Now,'dd-mm-yyyy--HH-MM')],'Preferences');
Screen('CloseAll');
catch exception
    Screen('CloseAll');
    disp(exception.message);
    sca;
end
end
