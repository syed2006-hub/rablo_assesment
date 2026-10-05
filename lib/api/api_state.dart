import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Enumeration of all fundamental view states for API and dynamic data streams
enum ViewState {
  initial,
  loading,
  success,
  empty,
  error,
}

/// Generic wrapper encapsulating API execution state and typed payload
class ApiResult<T> {
  final ViewState state;
  final T? data;
  final String? errorMessage;
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;
  final DateTime timestamp;

  ApiResult({
    required this.state,
    this.data,
    this.errorMessage,
    this.statusCode,
    this.validationErrors,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ApiResult.initial() => ApiResult(state: ViewState.initial);

  factory ApiResult.loading() => ApiResult(state: ViewState.loading);

  factory ApiResult.success(T data, {int statusCode = 200}) => ApiResult(
        state: ViewState.success,
        data: data,
        statusCode: statusCode,
      );

  factory ApiResult.empty({String? message}) => ApiResult(
        state: ViewState.empty,
        errorMessage: message ?? 'No records found.',
      );

  factory ApiResult.error(
    String message, {
    int? statusCode,
    Map<String, dynamic>? validationErrors,
  }) =>
      ApiResult(
        state: ViewState.error,
        errorMessage: message,
        statusCode: statusCode,
        validationErrors: validationErrors,
      );

  bool get isLoading => state == ViewState.loading;
  bool get isSuccess => state == ViewState.success;
  bool get isEmpty => state == ViewState.empty;
  bool get isError => state == ViewState.error;
}

/// Reusable, reactive state builder widget handling the 4 standard API states:
/// 1. Loading State
/// 2. Success State
/// 3. Empty State
/// 4. Error State (with Retry action)
class DynamicStateView<T> extends StatelessWidget {
  final ViewState state;
  final T? data;
  final Widget Function(BuildContext context, T data) successBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, String error, VoidCallback? onRetry)? errorBuilder;
  final VoidCallback? onRetry;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final String? emptyActionText;
  final VoidCallback? onEmptyAction;
  final String? errorMessage;
  final int? statusCode;
  final EdgeInsetsGeometry padding;

  const DynamicStateView({
    super.key,
    required this.state,
    this.data,
    required this.successBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onRetry,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon,
    this.emptyActionText,
    this.onEmptyAction,
    this.errorMessage,
    this.statusCode,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.initial:
      case ViewState.loading:
        return loadingBuilder?.call(context) ?? _buildDefaultLoadingView();

      case ViewState.empty:
        return emptyBuilder?.call(context) ?? _buildDefaultEmptyView(context);

      case ViewState.error:
        final errorText = errorMessage ?? 'Unable to connect to the backend server. Please verify your connection.';
        return errorBuilder?.call(context, errorText, onRetry) ??
            _buildDefaultErrorView(context, errorText);

      case ViewState.success:
        if (data != null) {
          return successBuilder(context, data as T);
        } else {
          return emptyBuilder?.call(context) ?? _buildDefaultEmptyView(context);
        }
    }
  }

  // ---------------------------------------------------------------------------
  // 1. LOADING STATE WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildDefaultLoadingView() {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF163238),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBright.withValues(alpha: 0.15),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBright),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Loading dynamic records...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Syncing with backend API service',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. EMPTY STATE WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildDefaultEmptyView(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF142B31),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D3B42),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  emptyIcon ?? Icons.inbox_outlined,
                  size: 30,
                  color: AppColors.primaryBright,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle ?? 'No Data Available',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage ?? 'There are no active records found in the database for this view.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              if (onEmptyAction != null && emptyActionText != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBright,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onEmptyAction,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      emptyActionText!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else if (onRetry != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(
                      'Refresh Data',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ERROR STATE WIDGET (WITH RETRY ACTION)
  // ---------------------------------------------------------------------------
  Widget _buildDefaultErrorView(BuildContext context, String error) {
    return Padding(
      padding: padding,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1518),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF87171).withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E1C20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF87171).withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 28,
                  color: Color(0xFFF87171),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'API Request Failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (statusCode != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C1B20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HTTP $statusCode',
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please check your internet connection or try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11.5,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Retry Request',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
