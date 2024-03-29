package igrek.todotree.info

import android.app.Activity
import android.content.res.Resources
import android.text.method.LinkMovementMethod
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import com.google.android.material.snackbar.Snackbar
import igrek.todotree.R
import igrek.todotree.info.errorcheck.SafeClickListener
import igrek.todotree.info.errorcheck.safeExecute
import igrek.todotree.info.logger.Logger
import igrek.todotree.info.logger.LoggerFactory
import igrek.todotree.inject.LazyExtractor
import igrek.todotree.inject.appFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


open class UiInfoService {
    private val activity: Activity by LazyExtractor(appFactory.activity)

    private val infobars = HashMap<View?, Snackbar>()
    private var lastSnakbar: Snackbar? = null
    private val logger: Logger = LoggerFactory.logger

    open fun showSnackbar(
        info: String = "",
        infoResId: Int = 0,
        actionResId: Int = 0,
        indefinite: Boolean = false,
        durationMillis: Int = 0,
        action: (() -> Unit)? = null, // dissmiss by default
    ) {
        GlobalScope.launch(Dispatchers.Main) {
            val duration = when {
                indefinite -> Snackbar.LENGTH_INDEFINITE
                durationMillis > 0 -> durationMillis
                else -> Snackbar.LENGTH_LONG
            }
            val infoV = info.takeIf { it.isNotEmpty() } ?: resString(infoResId)

            // dont create new snackbars if one is already shown
            val view: View? = activity.findViewById(R.id.main_content_container)
            if (view == null) {
                logger.error("No main content view")
                Toast.makeText(activity.applicationContext, infoV, Toast.LENGTH_LONG).show()
                return@launch
            }
            var snackbar: Snackbar? = infobars[view]
            if (snackbar == null || !snackbar.isShown) { // a new one
                snackbar = Snackbar.make(view, infoV, duration)
            } else { // visible - reuse it one more time
                snackbar.duration = duration
                snackbar.setText(infoV)
            }

            if (actionResId > 0) {
                val actionV: () -> Unit = action ?: snackbar::dismiss
                val actionName = resString(actionResId)
                snackbar.setAction(actionName, SafeClickListener {
                    actionV.invoke()
                })
                val color = ContextCompat.getColor(activity, R.color.colorAccent)
                snackbar.setActionTextColor(color)
            }

            snackbar.show()
            lastSnakbar = snackbar
            infobars[view] = snackbar
        }
        logger.info("UI: snackbar: $info")
    }

    fun showInfo(
        infoResId: Int, vararg args: String?,
        indefinite: Boolean = false,
    ) {
        val info = resString(infoResId, *args)
        showSnackbar(info = info, actionResId = R.string.action_info_ok, indefinite = indefinite)
    }

    fun showInfo(info: String, indefinite: Boolean = false) {
        showSnackbar(info = info, actionResId = R.string.action_info_ok, indefinite = indefinite)
    }

    fun showInfoCancellable(info: String, indefinite: Boolean = false, action: (() -> Unit)) {
        showSnackbar(info = info, actionResId = R.string.action_undo, indefinite = indefinite, action=action)
    }

    fun showInfoAction(
        infoResId: Int,
        vararg args: String,
        actionResId: Int,
        indefinite: Boolean = false,
        durationMillis: Int = 0,
        action: () -> Unit,
    ) {
        val info = resString(infoResId, *args)
        showSnackbar(
            info = info,
            actionResId = actionResId,
            action = action,
            indefinite = indefinite,
            durationMillis = durationMillis,
        )
    }

    open fun showToast(message: String) {
        GlobalScope.launch(Dispatchers.Main) {
            Toast.makeText(activity.applicationContext, message, Toast.LENGTH_LONG).show()
        }
        logger.debug("UI: toast: $message")
    }

    fun showToast(messageRes: Int) {
        val message = resString(messageRes)
        showToast(message)
    }

    fun clearSnackBars() {
        GlobalScope.launch(Dispatchers.Main) {
            infobars.forEach { (_, snackbar) ->
                if (snackbar.isShown)
                    snackbar.dismiss()
            }
            infobars.clear()
        }
    }

    fun resString(resourceId: Int): String {
        return try {
            activity.resources.getString(resourceId)
        } catch (e: Resources.NotFoundException) {
            ""
        }
    }

    fun resString(resourceId: Int, vararg args: Any?): String {
        val message = resString(resourceId)
        return if (args.isNotEmpty()) {
            String.format(message, *args)
        } else {
            message
        }
    }

    fun dialog(titleResId: Int, message: String) {
        dialogThreeChoices(
                titleResId = titleResId,
                message = message,
                positiveButton = R.string.action_info_ok, positiveAction = {},
        )
    }

    fun dialog(titleResId: Int, messageResId: Int) {
        dialogThreeChoices(
                titleResId = titleResId,
                messageResId = messageResId,
                positiveButton = R.string.action_info_ok, positiveAction = {},
        )
    }

    fun dialogThreeChoices(
        titleResId: Int = 0, title: String = "",
        messageResId: Int = 0, message: CharSequence = "",
        positiveButton: Int = 0, positiveAction: () -> Unit = {},
        negativeButton: Int = 0, negativeAction: () -> Unit = {},
        neutralButton: Int = 0, neutralAction: () -> Unit = {},
        postProcessor: (AlertDialog) -> Unit = {},
        richMessage: Boolean = false,
        cancelable: Boolean = true,
    ) {
        GlobalScope.launch(Dispatchers.Main) {
            val alertBuilder = AlertDialog.Builder(activity)

            alertBuilder.setMessage(
                when {
                    messageResId > 0 -> resString(messageResId)
                    else -> message
                }
            )
            alertBuilder.setTitle(
                when {
                    titleResId > 0 -> resString(titleResId)
                    else -> title
                }
            )

            if (positiveButton > 0) {
                alertBuilder.setPositiveButton(resString(positiveButton)) { _, _ ->
                    safeExecute {
                        positiveAction.invoke()
                    }
                }
            }
            if (negativeButton > 0) {
                alertBuilder.setNegativeButton(resString(negativeButton)) { _, _ ->
                    safeExecute {
                        negativeAction.invoke()
                    }
                }
            }
            if (neutralButton > 0) {
                alertBuilder.setNeutralButton(resString(neutralButton)) { _, _ ->
                    safeExecute {
                        neutralAction.invoke()
                    }
                }
            }
            alertBuilder.setCancelable(cancelable)
            val alertDialog = alertBuilder.create()
            postProcessor.invoke(alertDialog)
            if (!activity.isFinishing) {
                alertDialog.show()
            }
            if (richMessage) {
                val textView = alertDialog.findViewById<TextView>(android.R.id.message)
                textView?.movementMethod = LinkMovementMethod.getInstance()
            }
        }
    }

}
