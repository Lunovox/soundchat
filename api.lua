modSoundChat = { }
modSoundChat.players = { }

if minetest.setting_getbool("soundchat")~= false then
	minetest.setting_set("soundchat", "true")
end

modSoundChat.doAlert = function(msg)
	if type(msg)=="string" and msg~="" then
		local players = minetest.get_connected_players()
		for _, player in pairs(players) do
			if player~=nil and player:is_player() then
				minetest.sound_play("sfx_alertfire", {object=player})
				local playername = player:get_player_name()
				minetest.chat_send_player(playername, "#######################################################################################")
				minetest.chat_send_player(playername, msg)
				minetest.chat_send_player(playername, "#######################################################################################")
			end
		end
		return true
	end
	return false
end

modSoundChat.doMute = function(playername)
	if type(playername)=="string" and playername~="" then
		if not modSoundChat.players[playername] then 
			modSoundChat.players[playername] = { }
		end
		modSoundChat.players[playername].mute = not (type(modSoundChat.players[playername].mute)=="boolean" and modSoundChat.players[playername].mute==true)
		if not modSoundChat.players[playername].mute then --Verifica se o chat esta ativado!
			minetest.chat_send_player(playername, "[SOUNDCHAT] O sonorizador de chat foi ativado!")
		else
			minetest.chat_send_player(playername, "[SOUNDCHAT] O sonorizador de chat foi desativado!")
		end
		return modSoundChat.players[playername].mute
	end
end

minetest.register_on_chat_message(function(name,msg)
	if minetest.setting_getbool("soundchat") and type(msg)=="string" and msg:len()>=3 then
		for i,player in ipairs(minetest.get_connected_players()) do
			if player~=nil and player:is_player()~=nil and player:get_player_name()~=nil and player:get_player_name()~=name then --Toca para todos ,exceto para quem enviou a mensagem.
				local playername = player:get_player_name()
				if not modSoundChat.players[playername] then 
					modSoundChat.players[playername] = { }
				end
				if modSoundChat.players[playername].handler ~=nil then 
					minetest.sound_stop(modSoundChat.players[playername].handler)
				end
				modSoundChat.players[playername].mute = (type(modSoundChat.players[playername].mute)=="boolean" and modSoundChat.players[playername].mute==true)
				
				
				if  
					string and string.len and string.find and string.lower
					and type(playername)=="string" and type(msg)=="string"
					and (
						string.find(string.lower(msg), string.lower(playername))
						or (string.len(msg)>=4 and string.find(string.lower(playername), string.lower(msg)))
					)
				then --#################### CHAMAR ATENÇÃO #########################################################
					modSoundChat.players[playername].handler = minetest.sound_play("sfx_chat_playername", {
						object = player, --Se retirar esta linha tocará para todos. (Provavelmente ¬¬)
						gain = 1.0, -- 1.0 = Volume total
						max_hear_distance = 1,
						loop = false,
					})
					break --para de executar o comando 'for'
				elseif not modSoundChat.players[playername].mute then --#################### CONVERSA COMUM #########################################################
					modSoundChat.players[playername].handler = minetest.sound_play("sfx_chat_speak", {
						object = player, --Se retirar esta linha tocará para todos. (Provavelmente ¬¬)
						gain = 1.0, -- 1.0 = Volume total
						max_hear_distance = 1,
						loop = false,
					})
				end
			end
		end --Fim de for
	end --Fim de if minetest.setting_getbool("soundchat") and msg and msg:len()>=2 then
end)

minetest.register_chatcommand("mute", { params="", privs={},
	description = "Ativa e desativa o som do seu proprio chat individual.",
	func = function(playername, param)
		modSoundChat.doMute(playername)
		return true
	end,
})

minetest.register_chatcommand("mudo", { params="", privs={},
	description = "Ativa e desativa o som do seu proprio chat individual.",
	func = function(playername, param)
		modSoundChat.doMute(playername)
		return true
	end,
})

minetest.register_chatcommand("alert", {
	params = "mensagem",
	description = "Faz uma aviso destacado para todos os players online.",
	privs = {server=true},
	func = function(playername, params)
		return modSoundChat.doAlert(params)
	end,
})

minetest.register_chatcommand("soundchat", {
	params = "",
	description = "Exibe todos os comando deste mod",
	privs = {},
	func = function(playername, param)
		minetest.chat_send_player(playername, "    ", false)
		minetest.chat_send_player(playername, "############################################################################################", false)
		minetest.chat_send_player(playername, "### SOUNDCHAT (em Portugues Brasileiro)                                                  ###", false)
		minetest.chat_send_player(playername, "### Code license: GNU AGPL                                                     ###", false)
		minetest.chat_send_player(playername, "############################################################################################", false)
		minetest.chat_send_player(playername, "FUNCAO:", false)
		minetest.chat_send_player(playername, "   * Emite Bit sonoro simples quando algum jogador digita no chat.", false)
		minetest.chat_send_player(playername, "   * Emite Alarme sonoro quando algum jogador digita o seu nome no chat.", false)
		minetest.chat_send_player(playername, "DEPENDENCIAS:", false)
		minetest.chat_send_player(playername, "   * Necessita da proprieda 'soundchat' no arquivo de configuracao '.conf'.", false)
		minetest.chat_send_player(playername, "SINTAXE:", false)
		minetest.chat_send_player(playername, "   * /mute", false)
		minetest.chat_send_player(playername, "   * /mudo", false)
		minetest.chat_send_player(playername, "       => Ativa e desativa o som simples do seu proprio chat individual. (Nao desativa o Alarme)", false)
		minetest.chat_send_player(playername, "   * /alert <mensagem>", false)
		minetest.chat_send_player(playername, "       => Exibe uma mensagem e um alerta estrondoso para todos os players.", false)
		minetest.chat_send_player(playername, "          (Necessita de Priv: server)", false)
		minetest.chat_send_player(playername, "############################################################################################", false)
		minetest.chat_send_player(playername, playername..", precione F10 e use a rolagem do mouse para ler todo este tutorial!!!", false)
	end,
})


