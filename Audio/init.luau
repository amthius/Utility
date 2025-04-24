local SoundService = game:GetService("SoundService")

type AudioProps = {
    Id: number,
    Volume: number?,
    SoundGroup: SoundGroup?
}

type AudioTbl = {[number]: AudioProps}

local Audio = {}

local DefaultSoundGroup = Instance.new("SoundGroup")
DefaultSoundGroup.Name = "Default"
DefaultSoundGroup.Parent = SoundService 


function Audio.new(inst: Instance, props: AudioProps)
    local sound = Instance.new("Sound")
    sound.SoundId = `rbxassetid://{tostring(props.Id)}`
    sound.SoundGroup = props.SoundGroup or DefaultSoundGroup
    sound.Volume = props.Volume or 1

    return sound
end

function Audio.FromInstance(inst: Instance, props: AudioProps)
    local sound = Instance.new("Sound")

    sound.SoundId = `rbxassetid://{tostring(props.Id)}`
    sound.SoundGroup = props.SoundGroup or DefaultSoundGroup
    sound.Volume = props.Volume or 1
    sound:Play()

    sound.Ended:Once(function()
        sound:Destroy()
    end)

    sound.Parent = inst
end

function Audio.FromInstanceRandom(inst: Instance, audios: AudioTbl)
    local random = audios[math.random(#audios)]
    local sound = Instance.new("Sound")

    sound.SoundId = `rbxassetid://{tostring(random.Id)}`
    sound.Volume = random.Volume or 1
    sound.SoundGroup = random.SoundGroup or DefaultSoundGroup
    sound:Play()

    sound.Ended:Once(function()
        sound:Destroy()
    end)

    sound.Parent = inst
end

function Audio.CreateSoundGroup(name: string)
    local new = Instance.new("SoundGroup")
    new.Name = name
    new.Parent = SoundService
    return new
end

function Audio.FetchSoundGroup(name: string)
    return SoundService:FindFirstChild(name)
end

function Audio.MuteAudio(bool: boolean, group: SoundGroup?)
    local sound_group = if group then group else DefaultSoundGroup
    sound_group.Volume = if bool then 0 else 1
end

return Audio