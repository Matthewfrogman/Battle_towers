extends Bullet

func upg_bullet(enemy: Enemy):
	if path[2] == 1:
		enemy.debuff(5, 0.5, 2, true)
	if path[2] == 2:
		#gives the enemy a debuff
		enemy.debuff(10, 0.5, 4, true)
