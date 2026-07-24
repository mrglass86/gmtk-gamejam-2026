# Audio credits

Every third-party audio source used by the game is released under Creative
Commons Zero (CC0 1.0). Attribution is not required by the license, but the
sources are listed here for provenance and jam review.

## Original family voices and household foley

Original family voice and household recordings were made for this project and
are used with the director/parent's permission. Director-selected takes provide
child and parent voice, door creaks, refrigerator sounds, wrapper crinkles, a
toilet flush, and sink water. No performer names are listed. The CC0 cues below
remain wired as fallbacks wherever an original pool is empty or does not yet
cover an event.

Runtime family takes use conservative clip-profiled spectral denoise
(`ffmpeg` `afftdn`, 6 dB reduction). The untouched originals and side-by-side
A/B copies remain in the repository, with per-take results recorded in
`game/audio/denoised/MANIFEST.md`. Takes without a sufficiently quiet profile
window are omitted from runtime pools so their corresponding CC0 fallback is
used instead. A23 has one director-requested exception: the 0.38 s
`caught_grunt_02` organic kid reaction has no clean profile window and uses its
untouched runtime copy.

## Kenney packs

- [UI Audio](https://www.kenney.nl/assets/ui-audio), CC0 — TV click-off,
  light-switch click, and toy squeak.
- [Impact Sounds](https://www.kenney.nl/assets/impact-sounds), CC0 — carpet,
  hardwood, and parent footsteps; soft snack-drop thud.
- [RPG Audio](https://www.kenney.nl/assets/rpg-audio), CC0 — creaky-floor step
  and held-door creak; snack pickup.
- [Music Jingles](https://www.kenney.nl/assets/music-jingles), CC0 — win and
  caught/lose stings.

## Freesound sources

The local OGG files are Freesound's preview encodes of the linked CC0 source
recordings.

- [Unintelligible Radio Chatter Loop by unfa](https://freesound.org/people/unfa/sounds/245761/),
  CC0 — positional TV murmur.
- [Ambient Lofi Melody Loop 75 BPM by holizna](https://freesound.org/people/holizna/sounds/629149/),
  CC0 — positional kitchen-speaker music.
- [Fridge hum 2 by FOSSarts](https://freesound.org/people/FOSSarts/sounds/740089/),
  CC0 — positional refrigerator hum.
- [Loopable Ticking Clock by OwlStorm](https://freesound.org/people/OwlStorm/sounds/212181/),
  CC0 — positional nightstand clock.
- [Chihuahua Puppy Whine by AustinXYZ](https://freesound.org/people/AustinXYZ/sounds/350593/),
  CC0 — pet alert whine.
- [Single Dog Bark (King Charles Spaniel) by JovianSounds](https://freesound.org/people/JovianSounds/sounds/502655/),
  CC0 — pet bark.
- [Footsteps_Carpet.wav by mlsulli](https://freesound.org/people/mlsulli/sounds/234855/),
  CC0 — eight edited player carpet-footstep takes.
- [Footsteps on wood floor by IENBA](https://freesound.org/people/IENBA/sounds/485421/),
  CC0 — eight edited player hardwood-footstep takes.

License: [Creative Commons CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
