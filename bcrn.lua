require("cbc")

tBcRN = {
	---
	--Atualiza os dados do cartao
	--@author Rafael Felisbino
	--@param tTrilha	- trilha contendo os dados
	fDefinirrValores = function(tTrilha)
		for sChave, xValor in pairs(tTrilha) do
			tTransCT.tDadosCartao[sChave] = xValor
		end
	end,
	
	---
	--Verifica se é preciso carregar as tabelas no PINPAD baseado no timestamp passado
	--@author Rodrigo Perazzo, Daniel Agra
	--@param sDataTabela	- Timestamp da última carga
	--@return Lógico		- true se é preciso carregar as novas tabelas ou false, em caso contrário.
	fPrecisaCarregarTabelas = function(sDataTabela)
		-- reverte a data para AAAAMMDDHH
		
		if sDataTabela then
			sDataTabela = string.sub(sDataTabela,5,8) .. string.sub(sDataTabela,3,4) .. string.sub(sDataTabela,1,2) .. string.sub(sDataTabela,9,10)
		else
			sDataTabela = '2000010100'
		end
			
		local filesToCheckUpdate = {"chipdata.tbl", "kdata.tbl", "term.tbl", "lojista.tbl"}
		local sMaiorData = hutil.pegaMaiorDataArquivos(filesToCheckUpdate, "%Y%m%d")

		local versaoTabela = sMaiorData
		if #gtVersaoTabelas >= 1 then
			--LogDebug('tem verstab=' .. gtVersaoTabelas[1].iTipoTabelas .. gtVersaoTabelas[1].iVersaoTabelas, 1, I_LOGDEBUG_TIPO_BC)
			versaoTabela = versaoTabela .. gtVersaoTabelas[1].iTipoTabelas .. gtVersaoTabelas[1].iVersaoTabelas
		else
			--LogDebug('nao tem verstab', 1, I_LOGDEBUG_TIPO_BC)
			versaoTabela = versaoTabela .. "00"
		end

		--printer.print("tonumber(sDataTabela) ~= tonumber(versaoTabela)")
		--printer.print(sDataTabela .. " ~= " .. versaoTabela)
		
		--LogDebug('data do pinpad=' .. tostring(sDataTabela) , 1, I_LOGDEBUG_TIPO_BC)
		--LogDebug('data dos tbl  =' .. tostring(versaoTabela) , 1, I_LOGDEBUG_TIPO_BC)
		
		
		
		--gerando hash dos arquivos
		local tHashs = hutil.getFilesHash(filesToCheckUpdate)
		
		--validando se arquivo de hash anterior existe
		if tHashs and not gtHashCargaTabelas then
			--LogDebug('arquivo de hash anterior nao existe. salvando e forcando', 1, I_LOGDEBUG_TIPO_BC)
			ioLib.salvarTabela(MAPA_DADO.T_HASH_CARGATABELAS, tHashs)
			return true
		end
		
		--comparando com hashs anteriores
		for i = 1, #tHashs do
			if i > #gtHashCargaTabelas then
				--LogDebug('qtd de hashs diferente. forcando carga', 1, I_LOGDEBUG_TIPO_BC)
				ioLib.salvarTabela(MAPA_DADO.T_HASH_CARGATABELAS, tHashs)
				return true
			elseif tHashs[i].hash ~= gtHashCargaTabelas[i].hash then
					--LogDebug('hash do arquivo ' .. tostring(filesToCheckUpdate[i]) .. ' mudou', 1, I_LOGDEBUG_TIPO_BC)
					--LogDebug(tostring(tHashs[i].hash) .. '~=' .. tostring(gtHashCargaTabelas[i].hash)  , 1, I_LOGDEBUG_TIPO_BC)
					ioLib.salvarTabela(MAPA_DADO.T_HASH_CARGATABELAS, tHashs)
					return true
			end
			
		end
		
		--LogDebug('sem mudanca de hash!', 1, I_LOGDEBUG_TIPO_BC)
		
		
		if(tonumber(sDataTabela) ~= tonumber(versaoTabela)) then
			--LogDebug('tem que carregar pelo timestamp', 1, I_LOGDEBUG_TIPO_BC)
			return true
		else
			--LogDebug('nao tem que carregar pelo timestamp', 1, I_LOGDEBUG_TIPO_BC)
			return false
		end
	end