% Initialize Parameters
totalTime = 100; % Total simulation time in seconds
dt = 0.1; % Time step in seconds
baselineWeight = 50; % Baseline weight of the tank in kg
time = 0:dt:totalTime; % Time vector

% Simulate Disturbances
waveAmplitude = 5; % Amplitude of wave motion
waveFrequency = 0.2; % Frequency of wave motion
waveDisturbance = waveAmplitude * sin(2 * pi * waveFrequency * time);
randomDisturbance = randn(size(time)); % Random noise
totalDisturbance = waveDisturbance + randomDisturbance;

% Modify Scale Readings to Simulate Adding Fish
addFishTime = 50; % Time to add fish in seconds
fishWeight = 10; % Weight of the fish in kg
scaleReading = baselineWeight + totalDisturbance; % Initial scale reading
scaleReading(time >= addFishTime) = scaleReading(time >= addFishTime) + fishWeight;

% Initialize Moving Average Filter
windowSize = 50; % Number of readings in the moving average window
sumReadings = 0; % Sum of readings
movingAvg = zeros(size(time)); % Moving average array
threshold = 1; % Threshold for detecting fish addition in kg
ignorePeriod = 10; % Time to ignore fish detection on startup in seconds
delayPeriod = 10; % Delay in seconds after detecting fish to wait for moving average stabilization
fishDetected = false;
estimatedFishWeight = 0;
stabilizationTime = 0;

% Perform Moving Average Calculations and Fish Detection
for i = 1:length(time)
    sumReadings = sumReadings + scaleReading(i);
    if i > windowSize
        sumReadings = sumReadings - scaleReading(i - windowSize);
    end
    movingAvg(i) = sumReadings / min(i, windowSize);

    if time(i) > ignorePeriod && ~fishDetected
        if movingAvg(i) > (baselineWeight + threshold)
            fishDetected = true;
            stabilizationTime = time(i) + delayPeriod;
        end
    end

    % Wait for Stabilization Period to End
    if fishDetected && time(i) >= stabilizationTime
        stabilizationStarted = true;
        estimatedFishWeight = movingAvg(i) - baselineWeight
        fishDetected = false;
    end
end

% Display Results
plot(time, scaleReading, 'b', time, movingAvg, 'r', time, 0);
legend('Scale Reading', 'Moving Average');
xlabel('Time (s)');
ylabel('Weight (kg)');
title('Fish Scale Readings and Moving Average Filter');
