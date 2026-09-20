<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_activityLog', function (Blueprint $table) {
            $table->bigIncrements('v_activityLogId');

            $table->unsignedBigInteger('v_userId')
                ->nullable();

            $table->string('v_actionType', 100);

            $table->string('v_tableName', 100)
                ->nullable();

            $table->unsignedBigInteger('v_recordId')
                ->nullable();

            $table->text('v_actionDescription')
                ->nullable();

            $table->string('v_ipAddress', 45)
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->foreign(
                'v_userId',
                'fk_activityLog_user'
            )
                ->references('v_userId')
                ->on('tbl_user')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_activityLog');
    }
};