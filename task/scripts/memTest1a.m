%% MEMORY TEST PART A%%
% In this task, participants now need to put stamps on the cards that they saw in
% the previous two tasks. In this part, they will stamp each card once. 

%% Create data file for main memory data
mem_filename = ['sub', int2str(subjectNumber), '_', date, '_mem1a_mri.txt'];
fileID = fopen(mem_filename, 'w');

%specify file format.
% Column 1: Subject number - f
% Column 2: Trial Number - f
% Column 3: Card stimulus - s
% Column 4: Condition - f
% Column 5: True stamp - s
% Column 6: Foil stamp - 1 condition - s
% Column 7: Foil stamp - 4 condition - s
% Column 8: Foil stamp - novel stamp - s
% Column 9: True stamp position (1 - 4) - f
% Column 10: Foil stamp - 1 position (1 - 4) - f
% Column 11: Foil stamp - 4 position (1 - 4) - f
% Column 12: Foil stamp - novel stamp position (1 - 4) - f
% Column 13: Button press - f
% Column 14: Button press RT - d
% Column 15: Trial Start - d
% Column 16: Trial End - d
% Column 17: ITI duration - d
% Column 18: ITI start - d
% Column 19: ITI end - d
% Column 20: block - f

formatSpec = '\n %f\t %f\t %s\t %f\t %s\t %s\t %s\t %s\t %f\t %f\t %f\t %f\t %f\t %d\t %d\t %d\t %d\t %d\t %d\t %f';

fileVars = {'sub','trial','stim','freqCond','truePair', 'foilLowFreq', ...
    'foilHighFreq','foilNovel','truePairPos','foilLowFreqPos','foilHighFreqPos', ...
    'foilNovelPos','memResp','memRT','memTrialStart', 'memTrialEnd', 'memTrialITI', ...
    'memTrialITIStart', 'memTrialITIEnd', 'block'};

for fV = 1:length(fileVars)
    PrintType = '%s';
    PrintfV = cell2mat(fileVars(fV));
    fprintf(fileID, [PrintType '\t'], PrintfV);
end

%% Define screen info
% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Define fixation cross
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
fixCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 3;

%% Define positions of 4 choices
xMargin = .25*screenXpixels;
pixelsBetweenPics = 50;
answerPicWidth = round((screenXpixels - (xMargin*2) - (3*pixelsBetweenPics))/4);
answerPicHeight = answerPicWidth;
yMargin = screenYpixels - (answerPicHeight + 200);

answerLoc1 = [xMargin yMargin xMargin+answerPicWidth yMargin + answerPicHeight];
answerLoc2 = answerLoc1 + [pixelsBetweenPics+answerPicWidth 0 pixelsBetweenPics+answerPicWidth 0];
answerLoc3 = answerLoc2 + [pixelsBetweenPics+answerPicWidth 0 pixelsBetweenPics+answerPicWidth 0];
answerLoc4 = answerLoc3 + [pixelsBetweenPics+answerPicWidth 0 pixelsBetweenPics+answerPicWidth 0];

rect1 = answerLoc1 + [(-10) (-10) 10 (10)];
rect2 = answerLoc2 + [(-10) (-10) 10 (10)];
rect3 = answerLoc3 + [(-10) (-10) 10 (10)];
rect4 = answerLoc4 + [(-10) (-10) 10 (10)];

%% Present instruction screen
memInstructions = imread('taskInstructionsA/mem1_instructions.jpeg');
memInstructions = imresize(memInstructions, [screenYpixels screenXpixels]);
Screen('PutImage', window, memInstructions); % put image on screen

% Flip to the screen
HideCursor();
Screen('Flip', window);
trigger = 0; %indicate that trigger hasn't sent yet

% Wait for scanner trigger
while trigger == 0
[keyIsDown, secs, keyCode] = KbCheck; %wait for trigger
    if keyIsDown == 1 && keyCode(scannerTrigger) == 1
        trigger = 1;
        taskStartTime = GetSecs;
    end
end

%% Start ITI
Screen('DrawLines', window, fixCoords,lineWidthPix, white, [xCenter yCenter]);
[~, beginningITIstart] = Screen('Flip', window);
WaitSecs(startITI);
beginningITIend = GetSecs();


%% Run trial for each row of the array
for i = 1:numCards %loop through the first 24 postcards so that each is presented once
% Load the images
cardImage = memStimArray{i, 1};
cardImage = imread(cardImage);
stamp1 = imread(memStimArray{i,2});
stamp2 = imread(memStimArray{i,3});
stamp3 = imread(memStimArray{i,4});
stamp4 = imread(memStimArray{i,5});

%resize card image
cardImage = imresize(cardImage, [300 300]); 

% Get the size of the image
[s1, s2, s3] = size(cardImage);

% Make the images into textures
cardTexture = Screen('MakeTexture', window, cardImage);
stamp1Texture = Screen('MakeTexture', window, stamp1);
stamp2Texture = Screen('MakeTexture', window, stamp2);
stamp3Texture = Screen('MakeTexture', window, stamp3);
stamp4Texture = Screen('MakeTexture', window, stamp4);

%define the card location
cardLocation = [((screenXpixels/2)-(s1/2)), 200, ((screenXpixels/2)+(s1/2)), 200+s2];

%define the stamp locations
for k = 1:4
    if memStimArray{i,6} == k
        stamp1loc = eval(['answerLoc' int2str(k)]);
    elseif memStimArray{i,7} == k
        stamp2loc = eval(['answerLoc' int2str(k)]);
    elseif memStimArray{i,8} == k
        stamp3loc = eval(['answerLoc' int2str(k)]);
    elseif memStimArray{i,9} == k
        stamp4loc = eval(['answerLoc' int2str(k)]);
    end
end
 
% Draw the card and stamps on the screen
Screen('DrawTexture', window, cardTexture, [], cardLocation, 0);
Screen('DrawTexture', window, stamp1Texture, [], stamp1loc, 0);
Screen('DrawTexture', window, stamp2Texture, [], stamp2loc, 0);
Screen('DrawTexture', window, stamp3Texture, [], stamp3loc, 0);
Screen('DrawTexture', window, stamp4Texture, [], stamp4loc, 0);

% Flip to the screen and start timer
[~, tStart] = Screen('Flip', window, [], 1);
disp(['Trial ' int2str(i) ' of first 24 associative memory trials']);

% Initialize response variables
respToBeMade = true;  
response = []; %initialize response 
rt = []; %initialize rt

    while respToBeMade == true && (GetSecs - tStart) < memTestMaxResponse % if a response has not been made and the maxtime has not elapsed
    [keyIsDown,secs, keyCode] = KbCheck; %check to see if a key has been pressed
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(button1)
            response = 1;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('FrameRect', window, grey, rect1, 10);
            Screen('Flip', window);
            WaitSecs(memTestMaxResponse - (GetSecs - tStart));
        elseif keyCode(button2)
            response = 2;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('FrameRect', window, grey, rect2, 10);
            Screen('Flip', window);
            WaitSecs(memTestMaxResponse - (GetSecs - tStart));
        elseif keyCode(button3)
            response = 3;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('FrameRect', window, grey, rect3, 10);
            Screen('Flip', window);
            WaitSecs(memTestMaxResponse - (GetSecs - tStart));
        elseif keyCode(button4)
            response = 4;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('FrameRect', window, grey, rect4, 10);
            Screen('Flip', window);
            WaitSecs(memTestMaxResponse - (GetSecs - tStart)); 
        end
    end
  
%% Close textures
Screen('Close', cardTexture);
Screen('Close', stamp1Texture);
Screen('Close', stamp2Texture);
Screen('Close', stamp3Texture);
Screen('Close', stamp4Texture);

tEnd = GetSecs;

%% ITI with jitter
itiInterval = memStimArray{i,11};

%draw fixation cross
Screen('FillRect', window, black);
Screen('DrawLines', window, fixCoords, lineWidthPix, white, [xCenter yCenter]); 
[~, ITIStart] = Screen('Flip', window); %display fixation cross
HideCursor(); 
WaitSecs(itiInterval); %wait for ITI duration
ITIEnd = GetSecs; %get end time
 
 %% Add info to data array
memDataArray{i,1} = subjectNumber;
memDataArray{i,2} = i;
memDataArray{i,3} = memStimArray{i,1}; %card stim
memDataArray{i,4} = memStimArray{i,10}; %condition
memDataArray{i,5} = memStimArray{i,2}; %true stamp
memDataArray{i,6} = memStimArray{i,3}; %foil stamp 1
memDataArray{i,7} = memStimArray{i,4}; %foil stamp 4
memDataArray{i,8} = memStimArray{i,5}; %foil stamp novel
memDataArray{i,9} = memStimArray{i,6}; %true stamp position
memDataArray{i,10} = memStimArray{i,7}; %foil stamp 1 position
memDataArray{i,11} = memStimArray{i,8}; %foil stamp 4 position
memDataArray{i,12} = memStimArray{i,9}; %foil stamp novel position
memDataArray{i,13} = response;
memDataArray{i,14} = rt; 
memDataArray{i,15} = tStart; 
memDataArray{i,16} = tEnd;
memDataArray{i,17} = memStimArray{i,11}; %ITI duration
memDataArray{i,18} = ITIStart;
memDataArray{i,19} = ITIEnd;
memDataArray{i,20} = block;
 
 %% Save data
 fileID = fopen(mem_filename, 'a');
 fprintf(fileID,formatSpec,memDataArray{i, :});
 
 %fprintf writes a space-delimited file.
 %Close the file.
 fclose(fileID);

end

%% END ITI
Screen('DrawLines', window, fixCoords,lineWidthPix, white, [xCenter yCenter]);
[~, endITIstart] = Screen('Flip', window);
WaitSecs(endITI);
endITIend = GetSecs();

%% Add beginning ITI to file
memDataArray{numCards + 1,1} = subjectNumber;
memDataArray{numCards + 1,2} = 0;
memDataArray{numCards + 1,3} = 'beginningITI'; %card stim
memDataArray{numCards + 1,4} = []; %condition
memDataArray{numCards + 1,5} = []; %true stamp
memDataArray{numCards + 1,6} = []; %foil stamp 1
memDataArray{numCards + 1,7} = []; %foil stamp 4
memDataArray{numCards + 1,8} = []; %foil stamp novel
memDataArray{numCards + 1,9} = []; %true stamp position
memDataArray{numCards + 1,10} = []; %foil stamp 1 position
memDataArray{numCards + 1,11} = []; %foil stamp 4 position
memDataArray{numCards + 1,12} = []; %foil stamp novel position
memDataArray{numCards + 1,13} = [];
memDataArray{numCards + 1,14} = []; 
memDataArray{numCards + 1,15} = []; 
memDataArray{numCards + 1,16} = [];
memDataArray{numCards + 1,17} = startITI; %ITI duration
memDataArray{numCards + 1,18} = beginningITIstart;
memDataArray{numCards + 1,19} = beginningITIend;
memDataArray{numCards + 1,20} = block;

%% Add ending ITI to file
memDataArray{numCards + 2,1} = subjectNumber;
memDataArray{numCards + 2,2} = numCards + 1;
memDataArray{numCards + 2,3} = 'endingITI'; %card stim
memDataArray{numCards + 2,4} = []; %condition
memDataArray{numCards + 2,5} = []; %true stamp
memDataArray{numCards + 2,6} = []; %foil stamp 1
memDataArray{numCards + 2,7} = []; %foil stamp 4
memDataArray{numCards + 2,8} = []; %foil stamp novel
memDataArray{numCards + 2,9} = []; %true stamp position
memDataArray{numCards + 2,10} = []; %foil stamp 1 position
memDataArray{numCards + 2,11} = []; %foil stamp 4 position
memDataArray{numCards + 2,12} = []; %foil stamp novel position
memDataArray{numCards + 2,13} = [];
memDataArray{numCards + 2,14} = []; 
memDataArray{numCards + 2,15} = []; 
memDataArray{numCards + 2,16} = [];
memDataArray{numCards + 2,17} = endITI; %ITI duration
memDataArray{numCards + 2,18} = endITIstart;
memDataArray{numCards + 2,19} = endITIend;
memDataArray{numCards + 2,20} = block;


%% Compute how well they did 
 for i = 1:size(memDataArray,1)
     if memDataArray{i,9} == memDataArray{i,13} %if the true stamp position = response
         memDataArray{i,21} = 1;
     else
         memDataArray{i,21} = 0;
     end
 end
 
 %Compute overall accuracy
 cardsStampedPart1 = sum(cellfun(@double,memDataArray(:,21)));


%% End screen
line1 = 'Great job!';
 
% Draw all the text in one go
Screen('TextSize', window, 30);
DrawFormattedText(window, [line1],'center', screenYpixels * 0.33, white);

% Flip to the screen
HideCursor();
[~, endScreenStart] = Screen('Flip', window);

%wait for end of run
timeElapsed = GetSecs - taskStartTime;
disp(['The memory test took ' int2str(timeElapsed) ' seconds.']);
WaitSecs(endTimeBuffer+3);
endScreenEnd = GetSecs;

%% Add end screen timing to file
memDataArray{numCards + 3,1} = subjectNumber;
memDataArray{numCards + 3,2} = numCards + 2;
memDataArray{numCards + 3,3} = 'endScreen'; %card stim
memDataArray{numCards + 3,4} = []; %condition
memDataArray{numCards + 3,5} = []; %true stamp
memDataArray{numCards + 3,6} = []; %foil stamp 1
memDataArray{numCards + 3,7} = []; %foil stamp 4
memDataArray{numCards + 3,8} = []; %foil stamp novel
memDataArray{numCards + 3,9} = []; %true stamp position
memDataArray{numCards + 3,10} = []; %foil stamp 1 position
memDataArray{numCards + 3,11} = []; %foil stamp 4 position
memDataArray{numCards + 3,12} = []; %foil stamp novel position
memDataArray{numCards + 3,13} = [];
memDataArray{numCards + 3,14} = []; 
memDataArray{numCards + 3,15} = []; 
memDataArray{numCards + 3,16} = [];
memDataArray{numCards + 3,17} = endTimeBuffer + 3; %ITI duration
memDataArray{numCards + 3,18} = endScreenStart;
memDataArray{numCards + 3,19} = endScreenEnd;
memDataArray{numCards + 3,20} = block;

 %% Save data
 fileID = fopen(mem_filename, 'a');
 fprintf(fileID,formatSpec,memDataArray{numCards + 1, :});
 fprintf(fileID,formatSpec,memDataArray{numCards + 2, :});
 fprintf(fileID,formatSpec,memDataArray{numCards + 3, :});
 fclose(fileID);
 
 %save task variables
save('taskVars.mat'); 

% Clear the screen
sca;




