function GeneratSequence()
%%��Pre_ExperimentͼƬ��˳�����Ŀ�걳����animal_match��vechile_match��
%%�ò����ˣ���Ҫ�������
animal_dir = 'G:\workdoc\matlab\psychtoolbox\animal\animal\transparent_cut\';
vehicle_dir = 'G:\workdoc\matlab\psychtoolbox\animal\vehicle\transparent_cut\';
vehicle = dir(vehicle_dir);
vehicle = vehicle(3:end);
animal = dir(animal_dir);
animal = animal(3:end);
%animal
N = 0;
for k=1:length(animal)
    %Ѱ������Ϊxxx_merge_yyy.*���ļ�,xxx����naimal���,yyy����vehicle���
    split = regexp(animal(k).name,'\.','split');
    pre_name = split{1,1};
    split = regexp(pre_name,'_','split');
    if length(split) ~= 3
        continue
    end
    %animal��ź�vehicle���
    num_str = split{1,1};
    pnum_str = split{1,end};
    pnum = str2num(pnum_str);
    if (~exist([animal_dir num_str '_bk.jpg']) && ...
        ~exist([animal_dir num_str '_bk.bmp']) && ...
        ~exist([animal_dir num_str '_bk.png'])) ||...
        ~exist([animal_dir num_str '.png']) ||...
        ~exist([animal_dir num_str '_merge.jpg'])
        fprintf('animalȱʧ!!!\n');
        continue
    end
    if exist('animai_match','var') && ismember(pnum,animal_match(:,2))
         fprintf ('�������ظ�!!!');
         sca;
    end
    N = N+1;
    %animal����Ӧvehicle�����ı��,num_str,pnum_str
    %animal��vehicle��Ӧ��ϵ
    animal_match(N,1) = str2num(num_str);
    animal_match(N,2) = pnum;
end

%vehicle
N = 0;
for k=1:length(vehicle)
    split = regexp(vehicle(k).name,'\.','split');
    pre_name = split{1,1};
    split = regexp(pre_name,'_','split');
    if length(split) ~= 3
        continue
    end
    num_str = split{1,1};
    pnum_str = split{1,end};
    pnum = str2num(pnum_str);
    if (~exist([vehicle_dir num_str '_bk.jpg']) && ...
        ~exist([vehicle_dir num_str '_bk.bmp']) && ...
        ~exist([vehicle_dir num_str '_bk.png'])) ||...
        ~exist([vehicle_dir num_str '.png']) ||...
        ~exist([vehicle_dir num_str '_merge.jpg'])
        fprintf('vehicleȱʧ!!!\n');
        continue
    end
    if exist('vehicle_match','var') && ismember(pnum,vehicle_match(:,2))
         fprintf ('�������ظ�!!!');
         sca;
    end
    N = N+1;
    %animal��vehicle��Ӧ��ϵ
    vehicle_match(N,1) = str2num(num_str);
    vehicle_match(N,2) = pnum;
end
save('./sequence/animal_match.mat','animal_match');
save('./sequence/vehicle_match.mat','vehicle_match');
end

