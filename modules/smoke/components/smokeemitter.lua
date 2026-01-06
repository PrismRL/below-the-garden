--- @class SmokeEmitter : Component
--- @field radius number            -- Radius the smoke spreads from the emitter
--- @field decay number             -- Amount the smoke weakens per decay tick
--- @field turnsUntilDecay number   -- Turns before decay begins
--- @field remove boolean           -- Whether the emitter removes itself after finishing
--- @overload fun(opts: { component: Component, loop: boolean?, radius: number, decay: number, turnsUntilDecay: number?, remove: boolean? }): SmokeEmitter
local SmokeEmitter = prism.Component:extend "SmokeEmitter"

function SmokeEmitter:__new(opts)
   self.component = opts.component
   self.radius = opts.radius
   self.decay = opts.decay
   self.turnsUntilDecay = opts.turnsUntilDecay or 0
   self.remove = opts.remove ~= false
   self.loop = opts.loop
   self.actor = opts.actor
   self.component = opts.component

   self._radius = self.radius
   self._decay = self.decay
   self._turnsUntilDecay = self.turnsUntilDecay
end

return SmokeEmitter
