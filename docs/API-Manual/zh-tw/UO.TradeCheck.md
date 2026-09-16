# UO.TradeCheck

ClassicUO • Runtime API

<!-- yoko-manual: 1 -->
<!-- yoko-locale: zh-tw -->

讀取同意核取方塊；三參數形式也能修改自己的方塊。

## 完整語法

```text
UO.TradeCheck(TradeNum:Any, Num:Any) -> Any
UO.TradeCheck(windowIndex:Any) -> Integer
UO.TradeCheck(windowIndex:Any, checkbox:Any, stateValue:Any) -> Integer
```

## 參數

- `windowIndex` — 目前視窗的整數索引：0..TradeCount()-1。負數或不存在的索引傳回空結果。不是 serial。
- `TradeNum` — 目前視窗的整數索引：0..TradeCount()-1。負數或不存在的索引傳回空結果。不是 serial。
- `Num` — 只適用兩參數形式：1 是自己的方塊，2 是對方方塊；其他值傳回 0。這裡 TradeNum 從 0 起。
- `checkbox` — 只適用三參數形式：0 是自己的方塊，1 是只能讀取的對方方塊；其他值傳回 0。
- `stateValue` — 只有 checkbox=0 時有效：0/FALSE 取消同意，任何非零數值/TRUE 設定同意。checkbox=1 時忽略。

## 傳回值

Integer：選定方塊已勾選時為 1 = TRUE；未勾選、缺少視窗或無效側別時為 0 = FALSE。寫入傳回的是狀態，不是交易成功：取消勾選傳回 0。

這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

## 行為

- GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade 從 1 編號；TradeContainer/TradeOpponent/TradeName 及所有 TradeCheck 形式從 0 索引。本客戶端保留這些慣例；不同引擎的外部手冊可能採用不同起點。
- 在遊戲執行緒讀取目前 World 中尚未關閉的視窗，排除已釋放視窗。讀取不送封包、不等待回覆。開啟、關閉或將視窗移到最前方可能改變 UI 順序；索引不是永久 ID。
- ConfirmTrade 及寫入自己的 TradeCheck 只在同意狀態改變時送封包。對方方塊由伺服器控制。CancelTrade 只送一次。1/TRUE 表示本機狀態或處理，不表示轉移完成。名稱與雙方勾選不能證明物品未變。

### 內部函式：從呼叫到結果

以下說明 C# 呼叫路徑，之後提供可執行的 Basic 範例。腳本不會重新實作網路協定。

#### 1. TradeCheck

註冊依參數數量選擇形式，NumberConversions 轉換數字。兩參數 TradeCheck 驗證 1/2 側別後映射到 bridge 的 0/1。舊形式 serial 由 ToHex 格式化。

Integer：選定方塊已勾選時為 1 = TRUE；未勾選、缺少視窗或無效側別時為 0 = FALSE。寫入傳回的是狀態，不是交易成功：取消勾選傳回 0。

專案原始碼: `external/InjectionScript/src/InjectionScript/Runtime/InjectionApiUO.cs`; 函式 `TradeCheck`.

#### 2. TradeCheck

Invoke 將讀寫轉到遊戲執行緒並支援腳本取消；讀取指定 TradingGump 的 ID1/ID2、LocalSerial、OpponentName 或核取狀態。

讀取同意核取方塊；三參數形式也能修改自己的方塊。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `TradeCheck`.

#### 3. FindTrade

FindNumberedTrade 在減 1 前檢查 number>0；FindTrade 拒絕負索引，只列舉目前 World 尚未關閉的 TradingGump。

GetTradeContainer/GetTradeOpponent/GetTradeOpponentName/ConfirmTrade/CancelTrade 從 1 編號；TradeContainer/TradeOpponent/TradeName 及所有 TradeCheck 形式從 0 索引。本客戶端保留這些慣例；不同引擎的外部手冊可能採用不同起點。

專案原始碼: `src/ClassicUO.Client/Game/Managers/ClassicUOInjectionApiBridge.cs`; 函式 `FindTrade`.

#### 4. AcceptTrade

自己的方塊改變時，GameActions.AcceptTrade 以代碼 2、ID1 及狀態呼叫 Send_TradeResponse。讀取及設定相同值不送封包。

Integer：選定方塊已勾選時為 1 = TRUE；未勾選、缺少視窗或無效側別時為 0 = FALSE。寫入傳回的是狀態，不是交易成功：取消勾選傳回 0。

專案原始碼: `src/ClassicUO.Client/Game/GameActions.cs`; 函式 `AcceptTrade`.

輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色 serial，不是價格或內容驗證。


## 範例

### 直接讀取或操作

```vb
# 直接讀取或操作
#
# 讀取同意核取方塊；三參數形式也能修改自己的方塊。
#
# Integer：選定方塊已勾選時為 1 = TRUE；未勾選、缺少視窗或無效側別時為 0 = FALSE。寫入傳回的是狀態，不是交易成功：取消勾選傳回 0。
#
# 這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result
# = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE
# 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

SUB Main()
    # TradeCheck(0) 與 TradeCheck(0,1) 讀取第一個視窗的自己方塊；TradeCheck(0,2) 讀取對方方塊。不寫入，也不自動同意。

    VAR own = UO.TradeCheck(0)
    VAR sameOwn = UO.TradeCheck(0, 1)
    VAR other = UO.TradeCheck(0, 2)
    UO.Print(CStr(own) + "/" + CStr(sameOwn) + "/" + CStr(other))
END SUB
```

**參數與執行說明:**

- TradeCheck(0) 與 TradeCheck(0,1) 讀取第一個視窗的自己方塊；TradeCheck(0,2) 讀取對方方塊。不寫入，也不自動同意。

### 另一情境與參數

```vb
# 另一情境與參數
#
# 讀取同意核取方塊；三參數形式也能修改自己的方塊。
#
# Integer：選定方塊已勾選時為 1 = TRUE；未勾選、缺少視窗或無效側別時為 0 = FALSE。寫入傳回的是狀態，不是交易成功：取消勾選傳回 0。
#
# 這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result
# = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE
# 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

SUB Main()
    # TradeCheck(0,0,FALSE) 取消自己的同意。TradeCheck(0,1,FALSE) 只讀對方：FALSE 不能改變對方同意。取消後傳回 0 是正常結果。

    VAR cleared = UO.TradeCheck(0, 0, FALSE)
    VAR other = UO.TradeCheck(0, 1, FALSE)
    UO.Print(CStr(cleared) + "/" + CStr(other))
END SUB
```

**參數與執行說明:**

- TradeCheck(0,0,FALSE) 取消自己的同意。TradeCheck(0,1,FALSE) 只讀對方：FALSE 不能改變對方同意。取消後傳回 0 是正常結果。

### 完整可呼叫輔助函式

```vb
# 完整可呼叫輔助函式
#
# 讀取同意核取方塊；三參數形式也能修改自己的方塊。
#
# Integer：選定方塊已勾選時為 1 = TRUE；未勾選、缺少視窗或無效側別時為 0 = FALSE。寫入傳回的是狀態，不是交易成功：取消勾選傳回 0。
#
# 這是邏輯結果：1 = TRUE，0 = FALSE。以 VAR result = command(...) 儲存後，可用 IF result = TRUE THEN 或 IF result
# = 1 THEN；否定結果用 IF result = FALSE THEN 或 IF result = 0 THEN。TRUE/FALSE
# 不加引號。只呼叫一次並儲存結果；重複呼叫可能再次執行動作或讀取已變更的狀態。

SUB Main()
    # 輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色
    # serial，不是價格或內容驗證。

    VAR accepted = BothAccepted(0)
    IF accepted = TRUE THEN
        UO.Print("Both boxes are checked; server completion is not known")
    END IF
END SUB

FUNCTION BothAccepted(index)
    IF index < 0 OR index >= UO.TradeCount() THEN
        RETURN FALSE
    END IF
    VAR own = UO.TradeCheck(index, 1)
    VAR other = UO.TradeCheck(index, 2)
    RETURN own = TRUE AND other = TRUE
END FUNCTION
```

**參數與執行說明:**

- 輔助函式完整列出並由 Main 呼叫。範圍/ID 檢查可減少錯誤，但多次呼叫不是原子操作，視窗可能在其間改變。操作中的 expectedPartner 是保存的角色 serial，不是價格或內容驗證。
