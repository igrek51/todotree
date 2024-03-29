package igrek.todotree.service.tree.persistence

import igrek.todotree.domain.treeitem.*
import igrek.todotree.exceptions.DeserializationFailedException
import igrek.todotree.info.logger.Logger
import igrek.todotree.info.logger.LoggerFactory
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

class JsonKtxTreeDeserializer {

    private val json = Json {
        ignoreUnknownKeys = true
        allowStructuredMapKeys = true
        prettyPrint = false
        useArrayPolymorphism = false
        isLenient = true
    }
    private val logger: Logger = LoggerFactory.logger

    @Throws(DeserializationFailedException::class)
    fun deserializeTree(data: String): AbstractTreeItem {
        val startTime = System.currentTimeMillis()

        var mData = data.trim { it <= ' ' }
        if (mData.endsWith(",")) // trim trailing comma at the end
            mData = mData.substring(0, mData.length - 1)
        // remove trailing commas in items
        mData = mData.replace("\\},\\n(\\s*)]".toRegex(), "}\n$1]")

        try {
            val rootTreeItem: JsonItem = json.decodeFromString(JsonItem.serializer(), mData)
            val result = mapJsonItemToTreeItem(rootTreeItem)

            val duration = System.currentTimeMillis() - startTime
            logger.debug("Tree deserialization done in $duration ms")
            return result
        } catch (e: SerializationException) {
            throw DeserializationFailedException(e.message)
        }
    }

    @Throws(DeserializationFailedException::class)
    private fun mapJsonItemToTreeItem(jsonItem: JsonItem): AbstractTreeItem {
        if (jsonItem.type == null) throw DeserializationFailedException("property 'type' not found")
        val treeItem: AbstractTreeItem = when (jsonItem.type) {
            "/" -> {
                RootTreeItem()
            }
            "text" -> {
                if (jsonItem.name == null) throw DeserializationFailedException("property 'name' not found")
                TextTreeItem(null, jsonItem.name!!)
            }
            "remote" -> {
                if (jsonItem.name == null) throw DeserializationFailedException("property 'name' not found")
                RemoteTreeItem(null, jsonItem.name!!)
            }
            "separator" -> {
                SeparatorTreeItem(null)
            }
            "link" -> {
                // name is optional, target required
                if (jsonItem.target == null) throw DeserializationFailedException("property 'target' not found")
                LinkTreeItem(null, jsonItem.target!!, jsonItem.name)
            }
            "checkbox" -> {
                if (jsonItem.name == null) throw DeserializationFailedException("property 'name' not found")
                val checked = "true" == jsonItem.checked
                CheckboxTreeItem(null, jsonItem.name!!, checked)
            }
            else -> throw DeserializationFailedException("Unknown item type: " + jsonItem.type)
        }
        if (jsonItem.items != null) {
            for (jsonChild in jsonItem.items!!) {
                if (jsonChild != null) {
                    treeItem.add(mapJsonItemToTreeItem(jsonChild))
                }
            }
        }
        return treeItem
    }

    @Serializable
    private data class JsonItem(
        var type: String? = null,
        var name: String? = null,
        var target: String? = null,
        var checked: String? = null,
        var items: List<JsonItem?>? = null,
    )
}
