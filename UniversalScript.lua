local function lerp(a, b, t)
	return a + (b - a) * t
end
function lerpColor3(a, b, t)
	local lerpedColor = Color3.new(
		a.r + (b.r - a.r) * t,
		a.g + (b.g - a.g) * t,
		a.b + (b.b - a.b) * t
	)
	return lerpedColor
end

local function tweenSequence(sequence, targetSequence, smoothness, timeTaken, objectToUpdate, propertyName, easeStyle, easeDirection)
	local sequenceType = false
	if typeof(sequence) == "NumberSequence" then
		sequenceType = "NumberSequence"
	elseif typeof(sequence) == "ColorSequence" then
		sequenceType = "ColorSequence"
	end
	assert(smoothness and type(smoothness) == "number" and smoothness > 0, "Invalid smoothness")
	assert(timeTaken and type(timeTaken) == "number" and timeTaken > 0, "Invalid timeTaken")
	assert(type(objectToUpdate[propertyName]) == "userdata" , "Invalid objectToUpdate")
	assert(propertyName and type(propertyName) == "string", "Invalid propertyName")
	if sequenceType == "NumberSequence" then
		local keypoints = sequence.Keypoints
		local targetKeypoints = targetSequence.Keypoints

		local originalTimes = {}
		local originalValues = {}
		local originalEnvelopes = {}
		for _, keypoint in ipairs(keypoints) do
			table.insert(originalTimes, keypoint.Time)
			table.insert(originalValues, keypoint.Value)
			table.insert(originalEnvelopes, keypoint.Envelope)
		end

		local function updateNumberSequence(progress)
			local newKeypoints = {}
			for i, originalTime in ipairs(originalTimes) do
				local closestTargetKeypointIndex = 1
				local closestTimeDifference = math.abs(originalTime - targetKeypoints[1].Time)
				for j, targetKeypoint in ipairs(targetKeypoints) do
					local timeDifference = math.abs(originalTime - targetKeypoint.Time)
					if timeDifference < closestTimeDifference then
						closestTimeDifference = timeDifference
						closestTargetKeypointIndex = j
					end
				end

				local targetValue = targetKeypoints[closestTargetKeypointIndex].Value
				local targetEnvelope = targetKeypoints[closestTargetKeypointIndex].Envelope

				local newValue = lerp(originalValues[i], targetValue, progress)
				local newEnvelope = lerp(originalEnvelopes[i], targetEnvelope, progress)
				table.insert(newKeypoints, NumberSequenceKeypoint.new(originalTime, newValue, newEnvelope))
			end
			return NumberSequence.new(newKeypoints)
		end

		for t = 0, 1, 1 / (smoothness * timeTaken) do
			local ta = game.TweenService:GetValue(t, easeStyle, easeDirection)
			local newNumberSequence = updateNumberSequence(ta)
			objectToUpdate[propertyName] = newNumberSequence
			task.wait(1 / smoothness)
		end

		local newKeypoints = {}
		for i, originalTime in ipairs(originalTimes) do
			local closestTargetKeypointIndex = 1
			local closestTimeDifference = math.abs(originalTime - targetKeypoints[1].Time)
			for j, targetKeypoint in ipairs(targetKeypoints) do
				local timeDifference = math.abs(originalTime - targetKeypoint.Time)
				if timeDifference < closestTimeDifference then
					closestTimeDifference = timeDifference
					closestTargetKeypointIndex = j
				end
			end

			local targetValue = targetKeypoints[closestTargetKeypointIndex].Value
			local targetEnvelope = targetKeypoints[closestTargetKeypointIndex].Envelope

			table.insert(newKeypoints, NumberSequenceKeypoint.new(originalTime, targetValue, targetValue))
		end
		objectToUpdate[propertyName] = NumberSequence.new(newKeypoints)
	elseif sequenceType == "ColorSequence" then
		local keypoints = sequence.Keypoints
		local targetKeypoints = targetSequence.Keypoints

		local originalTimes = {}
		local originalValues = {}
		for _, keypoint in ipairs(keypoints) do
			table.insert(originalTimes, keypoint.Time)
			table.insert(originalValues, keypoint.Value)
		end

		local function updateColorSequence(progress)
			local newKeypoints = {}
			for i, originalTime in ipairs(originalTimes) do
				local closestTargetKeypointIndex = 1
				local closestTimeDifference = math.abs(originalTime - targetKeypoints[1].Time)
				for j, targetKeypoint in ipairs(targetKeypoints) do
					local timeDifference = math.abs(originalTime - targetKeypoint.Time)
					if timeDifference < closestTimeDifference then
						closestTimeDifference = timeDifference
						closestTargetKeypointIndex = j
					end
				end

				local targetValue = targetKeypoints[closestTargetKeypointIndex].Value

				local newValue = lerpColor3(originalValues[i], targetValue, progress)
				table.insert(newKeypoints, ColorSequenceKeypoint.new(originalTime, newValue))
			end
			return ColorSequence.new(newKeypoints)
		end

		for t = 0, 1, 1 / (smoothness * timeTaken) do
			local ta = game.TweenService:GetValue(t, easeStyle, easeDirection)
			local newColorSequence = updateColorSequence(ta)
			objectToUpdate[propertyName] = newColorSequence
			task.wait(1 / smoothness)
		end

		local newKeypoints = {}
		for i, originalTime in ipairs(originalTimes) do
			local closestTargetKeypointIndex = 1
			local closestTimeDifference = math.abs(originalTime - targetKeypoints[1].Time)
			for j, targetKeypoint in ipairs(targetKeypoints) do
				local timeDifference = math.abs(originalTime - targetKeypoint.Time)
				if timeDifference < closestTimeDifference then
					closestTimeDifference = timeDifference
					closestTargetKeypointIndex = j
				end
			end

			local targetValue = targetKeypoints[closestTargetKeypointIndex].Value

			table.insert(newKeypoints, ColorSequenceKeypoint.new(originalTime, targetValue, targetValue))
		end
		objectToUpdate[propertyName] = ColorSequence.new(newKeypoints)
	end
end

-- fancy changeable values down here
local objectToUpdate = game.Workspace.Partt.ParticleEmitter
local attributeTweened = "Transparency"
local sequence = objectToUpdate[attributeTweened] -- don't change
local targetSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(1,0,0),
})
--[[ for color

local targetSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
	ColorSequenceKeypoint.new(1, Color3.new(0,0,1))
})

]]
local smoothness = 50 -- How smooth the tweening less smoothing = more choppy
local timeTaken = 5 -- In seconds
local easeStyle = Enum.EasingStyle.Exponential
local easeDirection = Enum.EasingDirection.Out
wait(3)
print('started')
task.spawn(tweenSequence, sequence, targetSequence, smoothness, timeTaken, objectToUpdate, attributeTweened, easeStyle, easeDirection)