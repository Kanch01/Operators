# Operators (Godot / GDScript)

**Operators** is a math-based roguelike where you defeat enemies by building correct expressions under time pressure. Every battle reinforces **order of operations (PEMDAS)**, if you don’t structure your expression correctly, you won’t deal damage and you might not deal any at all.

> **Demo:** (add link here)  

---

## Core Idea

In Operators, your “attacks” are **math expressions**. You assemble numbers and operators into an expression, submit it, and the evaluated result becomes the value used to damage the enemy.

The twist: battles are designed so you must respect **order of operations** to progress reliably—building the *right* expression is essential.

---

## Gameplay Loop

1. **Choose a path** on a procedurally-generated map. The default is 15 floors, but can easily be changed.
2. Enter rooms (battle / shop / heal / treasure) and **collect items** that change what math you can do, or **battle**.
3. In battles, build expressions quickly to **defeat enemies before they attack**.
4. Reach the final floor and fight the **boss**.

---

## Battle Rules (Math Mechanics)

### Default damage rule (division-based)
In the standard battle mode, your submitted result must be a **valid divisor** of the enemy’s current health to deal damage, otherwise your submission won’t “connect.”

This encourages players to:
- factor numbers quickly
- structure expressions cleanly
- use PEMDAS intentionally to hit exact target values

### Item/ability modifiers
Certain items can change battle rules temporarily, such as switching combat to a subtraction-based mode, forcing enemy HP to be even, or halving enemy HP.

---

## Time Pressure & Enemy Attacks

- Enemies attack on a timer (time/damage scales by progression tier).
- Defeating an enemy quickly can trigger bonuses if the player has certain items in their hand.

---

## Characters & Abilities

Playable characters each come with a signature ability, for example:
- **Cat** — *Eternal Clock*
- **Tiger** — *Rapid Strike*
- **Panda** — *Leisurely Parry*
- **Axolotl** — *Rested Soul*

---

## Items (Examples)

Operators includes both passive and consumable items that meaningfully change strategy:

- **Shield (Passive):** Permanently grants 3 shield; regenerates after every battle
- **Health UP (Passive):** +10 max HP and heal 10 (reverses if sold)
- **Double Cross (Passive):** Enables exponentiation using `**` (two consecutive multiplications)
- **Lucky Roll (Passive):** Reroll shop items (cost increases on consecutive rerolls)
- **Helping Hand (Passive):** Deals a new “hand” (double-click CLEAR)
- **Porta Heal (Consumable):** Full heal mid-battle (single use)
- **Perfect Split (Consumable):** Halves enemy HP (single use)
- **Stevens (Consumable):** Forces enemy HP to be even (single use)
- **Milk (Consumable):** Prevent statuses for 15 seconds (single use)
- **Subs (Consumable):** Switches battle to subtraction-based (single use)

---

## Map Generation

- **15 floors** with a branching layout
- Room types include:
  - **Battle**
  - **Shop**
  - **Heal**
  - **Treasure**
  - **Boss** (final floor)

The generator has paramaters so that players or facilitators can change the amount of floors or the probabilty a room appears. 

---

## Tech Stack

- **Engine:** Godot
- **Language:** GDScript
- **Genre:** Educational Roguelike / Battle Puzzle

---

## Running Locally

Download repo and open in Godot.

