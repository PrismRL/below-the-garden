--- @class SmokeEmitter : Component
--- @field radius number            -- Radius the smoke spreads from the emitter
--- @field decay number             -- Amount the smoke weakens per decay tick
--- @field turnsUntilDecay number   -- Turns before decay begins
--- @field remove boolean           -- Whether the emitter removes itself after finishing
--- @overload fun(opts: { radius: number, decay: number, turnsUntilDecay: number?, remove: boolean? }): SmokeEmitter
local SmokeEmitter = prism.Component:extend "SmokeEmitter"

function SmokeEmitter:__new(opts)
   self.radius = opts.radius
   self.decay = opts.decay
   self.turnsUntilDecay = opts.turnsUntilDecay or 0
   self.remove = opts.remove ~= false
end

return SmokeEmitter
