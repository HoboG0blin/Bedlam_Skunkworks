package data.hullmods;

import com.fs.starfarer.api.combat.BaseHullMod;
import com.fs.starfarer.api.combat.MutableShipStatsAPI;
import com.fs.starfarer.api.combat.ShipAPI.HullSize;

public class loosetorpedoes extends BaseHullMod {

	public void applyEffectsBeforeShipCreation(HullSize hullSize, MutableShipStatsAPI stats, String id) {
		stats.getHullDamageTakenMult().modifyMult(id, 0.8f);
		
		
	}
	
	public String getDescriptionParam(int index, HullSize hullSize) {
		return null;
	}
}
