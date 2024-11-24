function output = run_data(data, landmarks, Right)
[transform_tibia, transform_femur] = bone_to_tracker_transform(landmarks.tibia, landmarks.femur, Right);

angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b
Pin1_T_tc = transform_tibia.Pin1_T_tc;
Pin1_r_tc = transform_tibia.Pin1_r_tc;
Pin6_T_tc = transform_femur.Pin6_T_tc;
Pin6_r_tc = transform_femur.Pin6_r_tc;
%% Load tracked points
% Create matrices of tracker marker position and rotations in time

% Pin 1:
[gT_Pin1_ti] = findTrackerFixedFrames(data.tibia.rotations, data.tibia.translations);

% % Pin 6:
[gT_Pin6_ti] = findTrackerFixedFrames(data.femur.rotations, data.tibia.translations);

%% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position


 for i = 1:length(gT_Pin1_ti)


     %
     %                          Body fixed relative to global
     gTti{i,1} = gT_Pin1_ti{i,1}*Pin1_T_tc;
     %                          Position vectors of tibia origin in global
     grti{i,1} = gT_Pin1_ti{i,1}*Pin1_r_tc;
     % %                          Patella tendon insertion point in global
     %                          grtPTi{i,1} = gT_Pin1_ti{i,1}*Pin1_r_ptc;
     flagTibia(i,1) = 2;


     % Body fixed relative to global
     gTfi{i,1} = gT_Pin6_ti{i,1}*Pin6_T_tc;
     % Position vectors of tibia origin in global
     grfi{i,1} = gT_Pin6_ti{i,1}*Pin6_r_tc;
     flagFemur(i,1) = 10;





     % Calc motion of bones relative to each other

     % Tibia relative to femur:
     fTt{i,1} = gTfi{i,1}\gTti{i,1};
     fRt{i,1}=fTt{i,1}(1:3,1:3);

     %                       % Patella relative to femur:
     %                       fTp{i,1} = gTfi{i,1}\gTpi{i,1};


     % Convert points into femoral reference plane

     %                     % Tibial patella tendon insertion point in femoral frame of reference
     %                     frtPTi{i,1} = gTfi{i,1}\grtPTi{i,1};
     %                     % Patellar patella tendon insertion point in femoral frame of reference
     %                     frpPTi{i,1} = gTfi{i,1}\grpPTi{i,1};
     % Tibial origin point in femoral frame of reference
     frti{i,1} = gTfi{i,1}\(grti{i,1} - grfi{i,1});

     %Begin richard new version (v5)

     I_=gTfi{i,1}(1:3,1);%Femoral X axis unit vector, Grood and Suntay definition
     J_=gTfi{i,1}(1:3,2);%Femoral Y axis unit vector, Grood and Suntay definition
     K_=gTfi{i,1}(1:3,3);%Femoral Z axis unit vector, Grood and Suntay definition

     i_=gTti{i,1}(1:3,1);%Tibial x axis unit vector, Grood and Suntay definition
     j_=gTti{i,1}(1:3,2);%Tibial y axis unit vector, Grood and Suntay definition
     k_=gTti{i,1}(1:3,3);%Tibial z axis unit vector, Grood and Suntay definition
     %
     %                     pi_=gTpi{i,1}(1:3,1);%Patellar x axis unit vector, Grood and Suntay definition
     %                     pj_=gTpi{i,1}(1:3,2);%Patellar y axis unit vector, Grood and Suntay definition
     %                     pk_=gTpi{i,1}(1:3,3);%Patellar z axis unit vector, Grood and Suntay definition


     e1_=I_;%Femoral X axis in global reference frame, Grood and Suntay definition
     e3_=k_;%Tibial z axis in global reference frame, Grood and Suntay definition
     %                     pe3_=pk_;
     e2_=ucross(e3_,e1_);%Floating axis in global reference frame, Grood and Suntay definition
     %                     pe2_=ucross(pe3_,e1_);




     for TIBIOFEMORAL = 1
         [TFMatrixangles(i,:), TFMatrixtrans(i,:)] = rotationsAndTranslations(fTt{i}, Right);
         %                     Flexion(i,1)=asind(-dot(e2_,K_));
         %                     Flexion(i,1)=acosd(dot(J_,e2_));
         beta(i,1)=acosd(dot(I_,k_));
         if Right
             ExtRotation(i,1)=asind(dot(-e2_,i_));
             %                         ExtRotation(i,1)=acosd(dot(j_,e2_));
             Varus(i,1)=90-beta(i,1);
         else
             ExtRotation(i,1)=asind(dot(e2_,i_));
             %                         ExtRotation(i,1)=acosd(dot(j_,e2_));
             Varus(i,1)=-(90-beta(i,1));
         end


         %     H_=tibiaOrigin-femurOrigin;
         H_(i,:)=[grti{i,1}(1:3)-grfi{i,1}(1:3)]';%translation vector of from femoral origin to tibial origin (in global coordinate frame)
         if Right
             LatMed(i,1)=dot(H_(i,:),e1_);%projected onto the medial lateral axis e1
         else
             LatMed(i,1)=dot(H_(i,:),-e1_);
         end
         AntPost(i,1)=dot(H_(i,:),e2_);%projected onto the anterior posterior axis e2
         DistComp(i,1)=-dot(H_(i,:),e3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve

         output(i).flexion = TFMatrixangles(i,1);
         output(i).varus = Varus(i,1);
         output(i).external = ExtRotation(i,1);
         output(i).lateral = LatMed(i,1);
         output(i).anterior = AntPost(i,1);
         output(i).superior = DistComp(i,1);

     end

 end
end

