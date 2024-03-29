package igrek.todotree.intent

import android.os.Handler
import android.os.Looper
import igrek.todotree.activity.ActivityController
import igrek.todotree.app.AppData
import igrek.todotree.app.AppState
import igrek.todotree.info.logger.LoggerFactory
import igrek.todotree.inject.LazyExtractor
import igrek.todotree.inject.LazyInject
import igrek.todotree.inject.appFactory
import igrek.todotree.service.access.DatabaseLock
import igrek.todotree.settings.SettingsState
import igrek.todotree.system.WindowManagerService
import igrek.todotree.ui.GUI

class ExitCommand(
    appData: LazyInject<AppData> = appFactory.appData,
    gui: LazyInject<GUI> = appFactory.gui,
    settingsState: LazyInject<SettingsState> = appFactory.settingsState,
    lock: LazyInject<DatabaseLock> = appFactory.databaseLock,
    activityController: LazyInject<ActivityController> = appFactory.activityController,
    windowManagerService: LazyInject<WindowManagerService> = appFactory.windowManagerService,
) {
    private val appData by LazyExtractor(appData)
    private val gui by LazyExtractor(gui)
    private val settingsState by LazyExtractor(settingsState)
    private val lock by LazyExtractor(lock)
    private val activityController by LazyExtractor(activityController)
    private val windowManagerService by LazyExtractor(windowManagerService)

    private val logger = LoggerFactory.logger

    fun saveAndExitRequested() {
        Handler(Looper.getMainLooper()).post { quickSaveAndExit() }
    }

    fun saveItemAndExit() {
        if (appData.isState(AppState.EDIT_ITEM_CONTENT)) {
            gui.requestSaveEditedItem()
        }
        saveAndExitRequested()
    }

    fun exitDiscardingChanges() {
        activityController.exitingDiscardingChanges = true
        activityController.quit()
    }

    private fun quickSaveAndExit() {
        logger.info("Quick exiting...")
        Handler(Looper.getMainLooper()).post { postQuickSave() }
        activityController.minimize()
    }

    private fun postQuickSave() {
        PersistenceCommand().saveDatabase()
        windowManagerService.keepScreenOn(false)
        TreeCommand().navigateToRoot()
        lock.isLocked = settingsState.lockDB
        gui.showItemsList()
        logger.debug("Quick exit done")
    }
}