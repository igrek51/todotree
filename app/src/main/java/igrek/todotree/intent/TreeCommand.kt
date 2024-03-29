package igrek.todotree.intent

import igrek.todotree.domain.treeitem.AbstractTreeItem
import igrek.todotree.domain.treeitem.LinkTreeItem
import igrek.todotree.domain.treeitem.RemoteTreeItem
import igrek.todotree.domain.treeitem.RootTreeItem
import igrek.todotree.domain.treeitem.TextTreeItem
import igrek.todotree.exceptions.NoSuperItemException
import igrek.todotree.info.Toaster
import igrek.todotree.info.UiInfoService
import igrek.todotree.inject.LazyExtractor
import igrek.todotree.inject.LazyInject
import igrek.todotree.inject.appFactory
import igrek.todotree.service.access.DatabaseLock
import igrek.todotree.service.history.LinkHistoryService
import igrek.todotree.service.remote.RemotePushService
import igrek.todotree.service.remote.TodoDto
import igrek.todotree.service.tree.TreeManager
import igrek.todotree.service.tree.TreeScrollCache
import igrek.todotree.service.tree.TreeSelectionManager
import igrek.todotree.ui.GUI
import igrek.todotree.ui.treelist.TreeListLayout
import igrek.todotree.util.EmotionLessInator
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.joda.time.DateTime

@OptIn(DelicateCoroutinesApi::class)
class TreeCommand(
    treeManager: LazyInject<TreeManager> = appFactory.treeManager,
    gui: LazyInject<GUI> = appFactory.gui,
    uiInfoService: LazyInject<UiInfoService> = appFactory.uiInfoService,
    databaseLock: LazyInject<DatabaseLock> = appFactory.databaseLock,
    treeScrollCache: LazyInject<TreeScrollCache> = appFactory.treeScrollCache,
    treeSelectionManager: LazyInject<TreeSelectionManager> = appFactory.treeSelectionManager,
    remotePushService: LazyInject<RemotePushService> = appFactory.remotePushService,
    linkHistoryService: LazyInject<LinkHistoryService> = appFactory.linkHistoryService,
) {
    private val treeManager by LazyExtractor(treeManager)
    private val gui by LazyExtractor(gui)
    private val uiInfoService by LazyExtractor(uiInfoService)
    private val databaseLock by LazyExtractor(databaseLock)
    private val treeScrollCache by LazyExtractor(treeScrollCache)
    private val treeSelectionManager by LazyExtractor(treeSelectionManager)
    private val remotePushService by LazyExtractor(remotePushService)
    private val linkHistoryService by LazyExtractor(linkHistoryService)
    private val treeListLayout: TreeListLayout by LazyExtractor(appFactory.treeListLayout)

    private val emotionLessInator = EmotionLessInator()
    private val traversalMutex = Mutex()

    suspend fun goBack() {
        traversalMutex.withLock {
            try {
                val current = treeManager.currentItem!!
                // if item was reached from link - go back to link parent
                if (linkHistoryService.hasLink(current)) {
                    val linkFromTarget = linkHistoryService.getLinkFromTarget(current)
                    linkHistoryService.resetTarget(current)
                    linkFromTarget?.getParent()?.let { linkParent ->
                        treeManager.goTo(linkParent)
                    }
                } else {
                    treeManager.goUp()
                    linkHistoryService.resetTarget(current) // reset link target - just in case
                }
                treeListLayout.updateItemsList()
                treeScrollCache.restoreScrollPosition()
            } catch (e: NoSuperItemException) {
                ExitCommand().saveAndExitRequested()
            }
        }
    }

    suspend fun goBackUntilRoot() {
        // go back until root
        traversalMutex.withLock {
            try {
                val current = treeManager.currentItem!!
                // if item was reached from link - go back to link parent
                if (linkHistoryService.hasLink(current)) {
                    val linkFromTarget = linkHistoryService.getLinkFromTarget(current)
                    linkHistoryService.resetTarget(current)
                    linkFromTarget?.getParent()?.let { linkParent ->
                        treeManager.goTo(linkParent)
                    }
                } else {
                    treeManager.goUp()
                    linkHistoryService.resetTarget(current) // reset link target - just in case
                }
                treeListLayout.updateItemsList()
                treeScrollCache.restoreScrollPosition()
            } catch (_: NoSuperItemException) {
            }
        }
    }

    fun goStepUp() {
        // If entered link, it goes one step up to real link parent, breaking the history
        try {
            val current = treeManager.currentItem!!
            treeManager.goUp()
            linkHistoryService.resetTarget(current) // reset link target - just in case
            treeListLayout.updateItemsList()
            treeScrollCache.restoreScrollPosition()
        } catch (e: NoSuperItemException) {
            // ignoring
        }
    }

    fun itemGoIntoClicked(position: Int, item: AbstractTreeItem?) {
        databaseLock.unlockIfLocked(item)
        when (item) {
            is LinkTreeItem -> {
                goToLinkTarget(item)
            }
            is RemoteTreeItem -> {
                treeSelectionManager.cancelSelectionMode()
                goInto(position)

                runBlocking {
                    GlobalScope.launch(Dispatchers.Main) {
                        uiInfoService.showInfo("Fetching remote items…")
                        val deferred = remotePushService.populateRemoteItemAsync((item as RemoteTreeItem?)!!)
                        val result = deferred.await()
                        result.fold(onSuccess = { todoDtos: List<TodoDto> ->
                            treeListLayout.updateItemsList()
                            if (todoDtos.isEmpty()) {
                                uiInfoService.showInfo("No remote items")
                            } else {
                                val lastTimestamp = todoDtos.last().create_timestamp
                                val lastDate = lastTimestamp?.timestampSToString().orEmpty()
                                uiInfoService.showInfo("${todoDtos.size} remote items fetched.\nLast on $lastDate")
                            }
                        }, onFailure = { e ->
                            Toaster().error(e, "Communication breakdown!")
                        })
                    }
                }

                treeListLayout.updateItemsList()
                gui.scrollToItem(0)
            }
            else -> {
                treeSelectionManager.cancelSelectionMode()
                goInto(position)
                treeListLayout.updateItemsList()
                gui.scrollToItem(0)
            }
        }
    }

    fun goInto(childIndex: Int) {
        treeScrollCache.storeScrollPosition()
        treeManager.goInto(childIndex)
    }

    private fun navigateTo(item: AbstractTreeItem?) {
        treeScrollCache.storeScrollPosition()
        treeManager.goTo(item)
        treeListLayout.updateItemsList()
        gui.scrollToItem(0)
    }

    fun navigateToRoot() {
        navigateTo(treeManager.rootItem)
        linkHistoryService.clear()
    }

    fun markItemSelected(position: Int) {
        if (!treeSelectionManager.isAnythingSelected) {
            treeSelectionManager.startSelectionMode()
            treeSelectionManager.setItemSelected(position, true)
            treeListLayout.updateItemsList()
            gui.scrollToItem(position)
        } else {
            treeSelectionManager.setItemSelected(position, true)
            treeListLayout.updateItemsList()
        }
    }

    fun itemClicked(position: Int, item: AbstractTreeItem) {
        databaseLock.assertUnlocked()
        if (treeSelectionManager.isAnythingSelected) {
            when (treeSelectionManager.toggleItemSelected(position)) {
                true -> treeListLayout.updateItemsList()
                false -> treeListLayout.updateOneListItem(position)
            }
        } else {
            when (item) {
                is RemoteTreeItem -> {
                    itemGoIntoClicked(position, item)
                }
                is TextTreeItem -> {
                    when {
                        !item.isEmpty -> {
                            itemGoIntoClicked(position, item)
                        }
                        matchesSimplifiedName(item.displayName, "Tmp") && (item.getParent() == null || item.getParent() is RootTreeItem) -> {
                            itemGoIntoClicked(position, item)
                        }
                        else -> {
                            ItemEditorCommand().itemEditClicked(item)
                        }
                    }
                }
                is LinkTreeItem -> {
                    goToLinkTarget(item)
                }
            }
        }
    }

    private fun goToLinkTarget(item: LinkTreeItem) {
        // go into target
        val target = item.target
        if (target == null) {
            uiInfoService.showInfo("Link is broken: " + item.displayTargetPath)
        } else {
            linkHistoryService.storeTargetLink(target, item)
            navigateTo(target)
        }
    }

    fun findItemByPath(paths: Array<String>): AbstractTreeItem? {
        var current = treeManager.rootItem ?: return null
        for (path in paths) {
            current = findChildByLinkName(current, path) ?: return null
        }
        return current
    }

    private fun findChildByLinkName(item: AbstractTreeItem, name: String): AbstractTreeItem? {
        // find by exact name
        for (child in item.children) {
            if (child is TextTreeItem && child.displayName == name)
                return child
        }
        // find by simplified name
        val expectedSimplified = emotionLessInator.simplify(name)
        return item.children.firstOrNull {
            it is TextTreeItem && emotionLessInator.simplify(it.displayName) == expectedSimplified
        }
    }

    private fun matchesSimplifiedName(displayName: String, expected: String): Boolean {
        return emotionLessInator.simplify(displayName) == emotionLessInator.simplify(expected)
    }

    private fun Long.timestampSToString(): String {
        val datetime = DateTime(this * 1000)
        return datetime.toString("yyyy-MM-dd HH:mm:ss")
    }
}