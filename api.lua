modSoundChat = { }
modSoundChat.players = { }

if minetest.setting_getbool("soundchat")~= false then
	minetest.setting_set("soundchat", "true")
end
if minetest.setting_getbool("disable_escape_sequences")~= false then
	minetest.setting_set("disable_escape_sequences", "true")
	--core.colorize(color, message)
	--core.get_background_escape_sequence("#00ff00")
	--core.get_color_escape_sequence("#ff0000")
end

modSoundChat.doAlert = function(sendername, msg)
	if type(msg)=="string" and msg~="" then
		local players = minetest.get_connected_players()
		for _, player in pairs(players) do
			if player~=nil and player:is_player() then
				minetest.sound_play("sfx_alertfire", {object=player})
				local playername = player:get_player_name()
			
				local form = "\n"
					..core.get_color_escape_sequence("#ff0000").."#######################################################################################\n"
					..core.get_color_escape_sequence("#ff0000").."###    "..core.get_color_escape_sequence("#00ff00").."AVISO DO ADMINISTRADOR:\n"
					..core.get_color_escape_sequence("#ff0000").."###         "..core.get_color_escape_sequence("#ffffFF").." → "..msg.."\n"
					..core.get_color_escape_sequence("#ff0000").."#######################################################################################\n"
				minetest.chat_send_player(playername, form)
				--minetest.log('action',form)
			end
		end
		return true, ""
	else
		minetest.chat_send_player(sendername, "["..core.get_color_escape_sequence("#00ff00").."SOUNDCHAT"..core.get_color_escape_sequence("#ffffff")..":"..core.get_color_escape_sequence("#ff0000").."ERRO"..core.get_color_escape_sequence("#ffffff").."] "..core.get_color_escape_sequence("#8888ff").."/alert <message> ", false)
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
			minetest.chat_send_player(playername, "["..core.get_color_escape_sequence("#00ff00").."SOUNDCHAT"..core.get_color_escape_sequence("#ffffff").."] O sonorizador de chat foi "..core.get_color_escape_sequence("#00ffff").."ativado"..core.get_color_escape_sequence("#ffffff").."!")
		else
			minetest.chat_send_player(playername, "["..core.get_color_escape_sequence("#00ff00").."SOUNDCHAT"..core.get_color_escape_sequence("#ffffff").."] O sonorizador de chat foi "..core.get_color_escape_sequence("#ff0000").."desativado"..core.get_color_escape_sequence("#ffffff").."!")
		end
		local player = minetest.get_player_by_name(playername)
		if player ~=nil and player:is_player() then
			minetest.sound_play("sfx_chat2", {
				object = player, --Se retirar esta linha tocará para todos. (Provavelmente ¬¬)
				gain = 1.0, -- 1.0 = Volume total
				--max_hear_distance = 1,
				loop = false,
			})
		end
		return modSoundChat.players[playername].mute
	end
end

minetest.register_on_chat_message(function(sendername,msg)
	if minetest.setting_getbool("soundchat") and type(msg)=="string" and msg:len()>=3 then
		for i,player in ipairs(minetest.get_connected_players()) do
			if player~=nil 
				and player:is_player()~=nil 
				and player:get_player_name()~=nil 
				and player:get_player_name()~=sendername  --Toca para todos ,exceto para quem enviou a mensagem.
			then
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
					minetest.chat_send_player(playername, 
						core.get_color_escape_sequence("#00ffff").."O jogador "..core.get_color_escape_sequence("#ffff00")..sendername..core.get_color_escape_sequence("#00ffff").." citou seu nome!"
						, false
					)
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
